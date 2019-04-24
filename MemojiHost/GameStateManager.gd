extends Node

var currentRound = 0
var currentState = GAME_STATE.NOT_STARTED
var currentPrompt # Index starting from 0 that refers to the prompt players are currently voting on
var instructions = true # whether or not to show instructions before the actual game begins
var repeatInstruct = false # whether to show instructions for every round of the game
var finalPromptObj = null # Reference to final prompt for convenience

var players = [] # array of all players in the game
var audiencePlayers = [] # array of all players in the audience
var totalScoreTally = [] # array of scores for each player, in total
var competitors = [] # players who are competing in the current round of voting
var disconnected_players = [] # players who have disconnected

var lobbyCode = null

enum GAME_STATE {
	NOT_STARTED = 0
	GAME_STARTING = -1
	PROMPT_PHASE = 1
	VOTE_PHASE = 2
	RESULTS_PHASE = 3
	ROUND_RESULTS = 4
	FINAL_RESULTS = 5
	MULTI_PROMPT_PHASE = 6
	MULTI_VOTE_PHASE = 7
	MULTI_RESULTS_PHASE = 8
}

# arr - array to look in # id - playerID
func findPlayer(arr, id):
	for p in arr:
		if (p.playerID == id):
			return p
	return null

func debug_to_lobby():
	$ScreenManager.changeScreenTo(GlobalVars.LOBBY_SCREEN)

	var request = { "messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE, "letterCode": "????" }
	_on_ScreenManager_sendMessageToServer(request)

func _ready():
	$ScreenManager.connect("connectToServer", self, "connectToServer")
	$Networking.connect("_disconnectedFromServer", self, "on_Networking_connectionTimeout")
	$Networking.connect("connectedSuccessfully", self, "on_Networking_successful")
	$ScreenManager.connect("startGame", self, "on_startGame")
	$ScreenManager.connect("sendMessageToServer", self, "_on_ScreenManager_sendMessageToServer")
	$ScreenManager.connect("handleGameState", self, "_on_ScreenManager_handleGameState")
	$ScreenManager.connect("restart", self, "restartGame")
	$ScreenManager.connect("newGame", self, "toTitle")
	$ScreenManager.connect("instructionUpdate", self, "updateInstructions")
	toTitle()

func on_startGame():
	# set the instruction variables to what they need to be, only if screen is correct at the moment just in case
	setupGame()

func setupGame():
	# Check for if there are enough players joined
	if players.size() <= 2:
		# Not enough players are joined
		print("Not enough players joined")
		if $ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN:
			$ScreenManager.currentScreenInstance.showNotEnoughPlayers()
		return
	# Check for players are connected but no avatar is selected
	for player in players:
		if player.avatarID == null || player.username == null:
			# Not all players have an avatar selected
			print("Not all players have username or avatar")
			if $ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN:
				$ScreenManager.currentScreenInstance.showNotAllPlayersHaveAvatar()
			return

	if (currentState != GAME_STATE.NOT_STARTED): # NEW - Error checking for out of place calls
		return
	else:
		currentState = GAME_STATE.GAME_STARTING

	# Everything ok to start
	currentRound = 1
	var message = {"messageType":MESSAGE_TYPES.HOST_STARTING_GAME,
				"letterCode" : lobbyCode}
	# Send message to players
	$Networking.sendMessageToServer(message)
	yield(get_tree().create_timer(1), "timeout")
	
	promptPhase()

func promptPhase():
	currentState = GAME_STATE.PROMPT_PHASE
	
	# Clear prompts left from last round
	$PromptManager.reset()
	for player in players:
		player.reset_score()
		player.clear_prompts()
		player.clear_vote()
	for player in audiencePlayers:
		player.reset_score()
		player.clear_prompts()
		player.clear_vote()
	
	$ScreenManager.changeScreenTo(GlobalVars.WAIT_SCREEN)
	$Networking.connect("receivedPlayerAnswer", $ScreenManager.currentScreenInstance.confirmDisplay, "on_prompt_answer")
	$ScreenManager.currentScreenInstance.confirmDisplay.update_from_list(players)
	
	# Create message dictionary
	var messages_to_send = pair_players(players.size())
	sendPrompts(messages_to_send)

func sendPrompts(messages_to_send):
	print(messages_to_send)
	for m in messages_to_send:
		$Networking.sendMessageToServer(m)
		yield(get_tree().create_timer(1), "timeout")

func shufflePlayers(numPlayers):
	var shuffled_players = []
	var copy_players = [] + players
	var indexList = range(numPlayers)
	for i in range(numPlayers):
		randomize()
		var x = randi()%indexList.size()
		shuffled_players.append(copy_players[x])
		copy_players.remove(x)
		indexList.remove(x)
	return shuffled_players

func parse_prompt(prompt_text):
	var new_prompt_text = ""
	var prompt_strings = prompt_text.split("<username>")
	if prompt_strings.size() == 2:
		# This prompt contains a <username> space
		print("Prompt: " + str(prompt_text))
		print("Has a <username> in it")
		# Get a random user
		randomize()
		var x = randi()%players.size()
		new_prompt_text = str(prompt_strings[0]) + str(players[x].username) + str(prompt_strings[1])
		print("New prompt text: " + str(new_prompt_text))
	else:
		new_prompt_text = prompt_text
		print("New prompt text: " + str(new_prompt_text))
	return new_prompt_text

func pair_players(numPlayers):
	var messages = []
	var shuffled_players = shufflePlayers(numPlayers)
	print(shuffled_players)
	for i in range(numPlayers):
		var prompt = $PromptManager.create_prompt()
		# Initialize prompts with the players that are supposed to answer
		prompt.add_competitor(shuffled_players[i % numPlayers].playerID)
		prompt.add_competitor(shuffled_players[(i + 1) % numPlayers].playerID)
		# Store information in each player for which prompts they should answer
		shuffled_players[i % numPlayers].add_promptID(prompt.prompt_id)
		shuffled_players[(i + 1) % numPlayers].add_promptID(prompt.prompt_id)

		# Check if prompt contains <username>
		var prompt_text = prompt.get_prompt_text()
		prompt.set_prompt_text(parse_prompt(prompt_text))
		messages.append({
			"messageType":MESSAGE_TYPES.HOST_SENDING_PROMPT,
			"letterCode": lobbyCode,
			"promptID": prompt.get_prompt_id(),
			"prompt": prompt.get_prompt_text(),
			"playerID": shuffled_players[i % numPlayers].playerID
		})
		messages.append({
			"messageType":MESSAGE_TYPES.HOST_SENDING_PROMPT,
			"letterCode": lobbyCode,
			"promptID": prompt.get_prompt_id(),
			"prompt": prompt.get_prompt_text(),
			"playerID": shuffled_players[(i + 1) % numPlayers].playerID
		})
	return messages

func votePhase(): # handle voting for one prompt
	var answers # Array
	var promptID # Integer
	var promptText
	var promptObj

	promptID = $PromptManager.active_prompt_ids[currentPrompt]
	answers = $PromptManager.get_answers_to_prompt(promptID)
	promptObj = $PromptManager.active_prompts[promptID]
	promptText = promptObj.prompt_text

	print("DEBUG: entered votephase")
	currentState = GAME_STATE.VOTE_PHASE

	# TODO: Reset everyone's stored votes
	for p in players:
		p.clear_vote()
	for p in audiencePlayers:
		p.clear_vote()
	for p in disconnected_players:
		p.clear_vote()

	# Change to VotingScreen if not already there and update it
	if ($ScreenManager.currentScreen != GlobalVars.SCREENS.VOTE_SCREEN):
		$ScreenManager.changeScreenTo(GlobalVars.SCREENS.VOTE_SCREEN)
	$ScreenManager.currentScreenInstance.display_emojis(answers[0], answers[1])
	$ScreenManager.currentScreenInstance.display_prompt_text(promptObj.get_prompt_text())
	sendAnswersForVoting(promptText, answers)

# Sends the Answers to Players corresponding to the promptID given
func sendAnswersForVoting(prompt_text, answers):
	print("DEBUG: sendAnswersForVoting!!!!")
	var message

	for index in range(answers.size()):
		message = {
			"messageType": MESSAGE_TYPES.HOST_SENDING_ANSWERS,
			"letterCode": lobbyCode,
			"prompt": prompt_text,
			"answers": answers
		}
		$Networking.sendMessageToServer(message)
		yield(get_tree().create_timer(1), "timeout")

func resultsPhase():
	var promptID = $PromptManager.active_prompt_ids[currentPrompt]
	var competitorIDs = $PromptManager.active_prompts[promptID].get_competitors()
	competitors = []
	for index in range(competitorIDs.size()):
		competitors.append(findPlayer(players, competitorIDs[index]))

	currentState = GAME_STATE.RESULTS_PHASE
	showResults()

func roundResults():
	currentState = GAME_STATE.ROUND_RESULTS
	showTotalResults()

func showResults():
	# Give IDs of players competing, also calculate array of who voted for what
	var promptID
	var answers
	
	var playerVote
	var audienceCount
	# Votes from players
	var results = [0, 0]
	var scores = [0, 0]
	# Audience votes
	var audienceResults = [0, 0]
	var aPercentages = [0, 0]
	
	var leftVoterIDs
	var rightVoterIDs
	var leftVoters = [] # Player array - Voted for left answer
	var rightVoters = [] # Player array - Voted for right answer

	promptID = $PromptManager.active_prompt_ids[currentPrompt]
	answers = $PromptManager.get_answers_to_prompt(promptID)
	leftVoterIDs = $PromptManager.get_supporters(promptID, 0)
	rightVoterIDs = $PromptManager.get_supporters(promptID, 1)

	leftVoters.resize(leftVoterIDs.size())
	rightVoters.resize(rightVoterIDs.size())

	for index in range(leftVoterIDs.size()):
		leftVoters[index] = findPlayer(players, leftVoterIDs[index])
	for index in range(rightVoterIDs.size()):
		rightVoters[index] = findPlayer(players, rightVoterIDs[index])

	$ScreenManager.changeScreenTo(GlobalVars.RESULTS_SCREEN)
	$ScreenManager.currentScreenInstance.displayAnswers(answers)
	
	#tally player votes for each result
	for p in players:
		playerVote = p.get_regular_vote()
		if (playerVote == 0):
			results[0] += 1
		elif (playerVote == 1):
			results[1] += 1
	# tally audience votes
	for p in audiencePlayers:
		playerVote = p.get_regular_vote()
		if (playerVote == 0):
			audienceResults[0] += 1
		elif (playerVote == 1):
			audienceResults[1] += 1
	
	scores.resize(2)
	aPercentages.resize(2)
	audienceCount = audiencePlayers.size()
	# Calculate audience percent
	if (audienceCount > 0):
		aPercentages[0] = 100 * (float(audienceResults[0]) / audiencePlayers.size())
		aPercentages[1] = 100 * (float(audienceResults[1]) / audiencePlayers.size())
	else:
		aPercentages[0] = 0
		aPercentages[1] = 0
	
	#calculate and display totals of scores
	scores[0] = $ScreenManager.currentScreenInstance.calculateTotals(1, results[0], aPercentages[0])
	scores[1] = $ScreenManager.currentScreenInstance.calculateTotals(2, results[1], aPercentages[1])
	#display who voted for each answer
	$ScreenManager.currentScreenInstance.displayVoters(leftVoters, rightVoters)
	#reset votes for next round now that they have been displayed

	var pIndex
	for x in range(0,players.size()):
		if competitors[0] == players[x]:
			pIndex = x
			players[x].increase_score(scores[0]) # NEW - replaces totalScoreTally
	# TODO: Remove this line
	totalScoreTally[pIndex] += scores[0]

	pIndex = 0
	for x in range(0,players.size()):
		if competitors[1] == players[x]:
			pIndex = x
			players[x].increase_score(scores[1]) # NEW - replaces totalScoreTally
	# TODO: Remove this line
	totalScoreTally[pIndex] += scoress[1]

func showTotalResults():
	$ScreenManager.changeScreenTo(GlobalVars.TOTAL_SCREEN)
	# TODO: change this function
	$ScreenManager.currentScreenInstance.displayResults(totalScoreTally, players)
	#time till reset
	"""var t = Timer.new()
	t.setWaitTime(30)
	t.setOneShot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	toTitle()
	"""

func multiPromptPhase():
	var messageArr = []
	
	currentState = GAME_STATE.MULTI_PROMPT_PHASE
	print("DEBUG: Multi Prompt reached! Woot")
	$ScreenManager.changeScreenTo(GlobalVars.WAIT_SCREEN)
	$Networking.connect("receivedPlayerAnswer", $ScreenManager.currentScreenInstance.confirmDisplay, "on_prompt_answer")
	$ScreenManager.currentScreenInstance.confirmDisplay.update_from_list(players)
	
	# Generate final prompt
	finalPromptObj = $PromptManager.create_prompt()
	for p in players:
		finalPromptObj.add_competitor(p.playerID) # prepare prompt for answewrs
		var message = {
				"messageType":MESSAGE_TYPES.HOST_SENDING_PROMPT,
				"letterCode": lobbyCode,
				"promptID": finalPromptObj.get_prompt_id(),
				"prompt": finalPromptObj.get_prompt_text(),
				"playerID": p.playerID
		}
		messageArr.append(message) # Populate messages to send
	
	sendPrompts(messageArr)

func multiVotePhase():
	currentState = GAME_STATE.MULTI_VOTE_PHASE
	$ScreenManager.changeScreenTo(GlobalVars.MULTI_VOTE_SCREEN)
	var message
	
	message = {
		"messageType": MESSAGE_TYPES.HOST_SENDING_ANSWERS,
		"lettercode": lobbyCode,
		"promptID": finalPromptObj.get_prompt_id()
	}
	
	sendAnswersForVoting(finalPromptObj.get_prompt_text(), finalPromptObj.get_answers())
	
	
func multiResultsPhase():
	return

func advanceGame():
	print("DEBUG: Advance Game function")
	match (currentState):
		GAME_STATE.PROMPT_PHASE:
			print("DEBUG: Calling votephase")
			currentPrompt = 0
			votePhase()

		GAME_STATE.VOTE_PHASE:
			resultsPhase()

		GAME_STATE.RESULTS_PHASE: # Which prompt won in one phase of voting
			# TODO: check if last round of voting, then continue to final prompt
			currentPrompt += 1
			if (currentPrompt < players.size()): # Check for prompt completion
				votePhase()
			else:
				#TODO:
				roundResults()
			
		GAME_STATE.ROUND_RESULTS:
			currentRound += 1
			if (currentRound < 3):
				promptPhase() # TODO: Make sure PromptManager is reset
			else:
				# currentPrompt is the correct value
				multiPromptPhase()
		GAME_STATE.MULTI_PROMPT_PHASE:
			multiVotePhase()
		GAME_STATE.MULTI_VOTE_PHASE:
			pass
		GAME_STATE.MULTI_RESULTS_PHASE:
			pass
		GAME_STATE.FINAL_RESULTS:
			pass

func updatePlayerGameState(player):
	var message = { "messageType": MESSAGE_TYPES.UPDATE_PLAYER_GAME_STATE, "playerID": player.playerID, "gameState": currentState }
	match (currentState):
		GAME_STATE.NOT_STARTED:
			pass
		GAME_STATE.PROMPT_PHASE:
			# Get prompts
			var prompt_IDs = []
			var prompt_text = []
			print(player.get_promptIDs())
			for prompt_id in player.get_promptIDs():
				prompt_IDs.append(prompt_id)
				prompt_text.append($PromptManager.get_prompt_by_id(prompt_id).get_prompt_text())
			message["promptIDs"] = prompt_IDs
			message["promptText"] = prompt_text
		GAME_STATE.VOTE_PHASE:
			# Get vote options
			var promptID = $PromptManager.active_prompt_ids[currentPrompt]
			var answers = $PromptManager.get_answers_to_prompt(promptID)
			var promptObj = $PromptManager.active_prompts[promptID]
			var promptText = promptObj.prompt_text
			message["answers"] = answers
			message["prompt"] = promptText
		GAME_STATE.RESULTS_PHASE:
			pass
		GAME_STATE.ROUND_RESULTS:
			pass
		GAME_STATE.FINAL_RESULTS:
			pass
	$Networking.sendMessageToServer(message)


func quitHosting():
	pass

# Goes to the title screen and resets variables
func toTitle():
	if (lobbyCode != null):
		var endRequest = { "messageType": MESSAGE_TYPES.HOST_SHUTTING_DOWN, "letterCode": lobbyCode }
		$Networking.sendMessageToServer(endRequest)
	# Disconnect even if lobby code hasn't been requested yet
	$Networking.disconnectHostFromServer()

	players.clear()
	audiencePlayers.clear()
	currentState = GAME_STATE.NOT_STARTED
	totalScoreTally.clear()
	competitors.clear()
	lobbyCode = null

	$ScreenManager.changeScreenTo(GlobalVars.TITLE_SCREEN)

func connectToServer():
	$Networking.connectHostToServer($Networking.defaultServerIP, $Networking.defaultServerPort)

func on_Networking_connectionTimeout():
	if $ScreenManager.currentScreen == GlobalVars.TITLE_SCREEN:
		$ScreenManager.currentScreenInstance.show_connection_error()

func on_Networking_successful():
	print("Networking returned successful")
	if $ScreenManager.currentScreen == GlobalVars.TITLE_SCREEN:
		$ScreenManager.changeScreenTo(GlobalVars.SETUP_SCREEN)

func _on_Networking_obtainedLetterCode(letterCode):
	lobbyCode = letterCode

	if ($ScreenManager.currentScreen == GlobalVars.SETUP_SCREEN):
		$ScreenManager.currentScreenInstance.update_lettercode(letterCode)
		pass
	elif ($ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN):
		$ScreenManager.currentScreenInstance.update_lettercode(letterCode)
		pass

func _on_Networking_playerConnected(playerID, isPlayer):
	# Add new player to players array
	var player
	player = GlobalVars.PlayerClass.new()
	player.playerID = playerID
	player.isPlayer = isPlayer

	if (isPlayer):
		players.append(player)
		totalScoreTally.append(0)

		if ($ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN):
			$ScreenManager.currentScreenInstance.add_player_id(playerID)
	else:
		audiencePlayers.append(player)
		if ($ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN):
			$ScreenManager.currentScreenInstance.update_audience(audiencePlayers.size())

func _on_Networking_playerDisconnected(playerID):
	# Remove player from array
	for player in players:
		if (player.playerID == playerID):
			players.erase(player)
			if ($ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN):
				$ScreenManager.currentScreenInstance.update_from_list(players)
			return # unecessary to check audience since player already found

	for member in audiencePlayers:
		if (member.playerID == playerID):
			audiencePlayers.erase(member)
			if ($ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN):
					$ScreenManager.currentScreenInstance.update_audience(audiencePlayers.size())
			return


func _on_Networking_playerReconnected(playerID):
	for dc_player in disconnected_players:
			if dc_player.playerID == playerID:
				# Previously disconnected player
				# Handle reconnection
				print("DEBUG MESSAGE: Player connecting had been previously connected")
				# Update player based on gamestate
				players.append(dc_player)
				updatePlayerGameState(dc_player)
	pass # replace with function body


func _on_Networking_receivedPlayerDetails(playerID, username, avatarIndex):
	# TODO - check that no duplicate username or icon
	for player in players:
		if player.playerID == playerID:
			player.username = username
			player.avatarID = int(avatarIndex)

			var message = {"messageType":MESSAGE_TYPES.ACCEPTED_USERNAME_AND_AVATAR,
				"letterCode" : lobbyCode,
				"playerID" : playerID,
				"username" : username,
				"avatarIndex" : avatarIndex}
			$Networking.sendMessageToServer(message)

			if ($ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN):
				$ScreenManager.currentScreenInstance.update_player_status(player)

func _on_Networking_receivedPlayerAnswer(playerID, promptID, emojiArray):
	var message

	promptID = int(promptID)

	print ("DEBUG: received player answer")

	if (currentState == GAME_STATE.PROMPT_PHASE):
		for player in players:
			if player.playerID == playerID:
				print("[DEBUG]: remove current prompt from currentPrompt Array")
				print("[DEBUG]: Before:")
				print(player.get_promptIDs())
				player.currentPromptIDs.erase(promptID)
				print(player.get_promptIDs())
				player.answeredPromptIDs.append(promptID)
		if ($PromptManager.set_answer(int(promptID), playerID, emojiArray)):
			message = {
				"messageType": MESSAGE_TYPES.ACCEPTED_PROMPT_RESPONSE,
				"letterCode": lobbyCode,
				"playerID": playerID
			}
			$Networking.sendMessageToServer(message)

		if ($PromptManager.check_completion()):
			advanceGame()
	elif (currentState == GAME_STATE.MULTI_PROMPT_PHASE):
		for player in players:
			if (player.playerID == playerID):
				pass # TODO: provide for disconnect/reconnect
				
		if ($PromptManager.set_answer(promptID, playerID, emojiArray)):
			message = {
				"messageType": MESSAGE_TYPES.ACCEPTED_PROMPT_RESPONSE,
				"letterCode": lobbyCode,
				"playerID": playerID
			}
		
		if ($PromptManager.check_completion()):
			advanceGame()
	# TODO: Multi Prompt Phase


func _on_Networking_receivedPlayerVote(playerID, voteID):
	var message
	var promptID

	var playerObj
	var playerFlag = true # becomes false for audience member

	if (currentState == GAME_STATE.VOTE_PHASE):
		promptID = $PromptManager.active_prompt_ids[currentPrompt]
		voteID = int(voteID)

		# Update player/audience objects to store vote
		playerObj = findPlayer(players, playerID)
		if (playerObj == null): # Find audience if not a player
			playerObj = findPlayer(audiencePlayers, playerID)
			playerFlag = false
		else:
			playerFlag = true

		if (playerObj == null):
			return # TODO: handle error?
		else: # Player/Audience exists
			playerObj.regular_vote(voteID)
			print("DEBUG: recorded vote of ", playerID)

		# TODO: Redo this later
		var temp = $PromptManager.set_vote(promptID, playerID, voteID)
		print("DEBUG: set_vote - ", temp)

		message = {
			"messageType": MESSAGE_TYPES.ACCEPTED_VOTE_RESPONSE,
			"letterCode": lobbyCode,
			"playerID": playerID
		}
		$Networking.sendMessageToServer(message)

		# TODO: Change this
		# Check that all votes are in
		if ($PromptManager.check_votes(players, audiencePlayers)):
			advanceGame()


func _on_Networking_receivedPlayerMultiVote(playerID, promptID, voteArray):
	var message
	var playerObj
	var localPromptID
	
	if (currentState != GAME_STATE.MULTI_VOTE_PHASE):
		return

	if (voteArray.size() < 3): # check voteArray size
		return # TODO: Maybe error handle

	playerObj = findPlayer(players, playerID)
	if (playerObj == null): # Find audience if not a player
		playerObj = findPlayer(audiencePlayers, playerID)
	if (playerObj == null):
		return # Did not find player
	
	# Store multivote
	playerObj.multi_vote(voteArray[0], voteArray[1], voteArray[2])
	
	message = {
		"messageType": MESSAGE_TYPES.ACCEPTED_MULTI_VOTE,
		"letterCode": lobbyCode,
		"playerID": playerID
	}
	
	$Networking.sendMessageToServer(message)
	
	# TODO: Check vote completion for final round
	if ($PromptManager.check_votes(players, audiencePlayers, true)):
			advanceGame()


func _on_Networking_playerBadDisconnect(playerID):
	print("DEBUG MESSAGE: Player Bad Disconnect")
	# Find player based on playerID
	for player in players:
		if player.playerID == playerID:
			print("DEBUG MESSAGE: Player found")
			players.erase(player)
			if ($ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN):
				$ScreenManager.currentScreenInstance.update_from_list(players)
			else:
				disconnected_players.append(player)
			return
	
	# TODO: Do we need to handle audience?


func _on_ScreenManager_sendMessageToServer(msg):
	print("DEBUG MESSAGE: Message Sending")
	$Networking.sendMessageToServer(msg)


func _on_ScreenManager_handleGameState(msg):
	if $ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN:
		if (msg == "code" && lobbyCode != null):
			$ScreenManager.currentScreenInstance.update_lettercode(lobbyCode)
			return
		elif (msg == "disconnectLobby"):
			toTitle()
			return
		elif (msg == "startGame"): # NEW
			setupGame()
			return
	elif $ScreenManager.currentScreen == GlobalVars.RESULTS_SCREEN:
		if (msg == "advance"):
			advanceGame()
			return
	elif $ScreenManager.currentScreen == GlobalVars.TOTAL_SCREEN:
		if (msg == "advance"):
			print("DEBUG: **** TotalScreen advanceGame() ****")
			advanceGame()
			return
	elif $ScreenManager.currentScreen == GlobalVars.VOTE_SCREEN:
		if (msg == "advance"):
			advanceGame()
			return


func _on_Networking_lostConnection():
	$ScreenManager.lost_connection()
	pass # replace with function body


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if $Networking.socket.is_connected_to_host():
			var message = {
				"messageType": 130,
				"letterCode": $Networking.letterCode
			}
			$Networking.sendMessageToServer(message)
		get_tree().quit()


func restartGame():
	instructions = false
	repeatInstruct = false
	totalScoreTally = []
	setupGame()

func updateInstructions(instruct, repeat):
	instructions = instruct
	repeatInstruct = repeat
