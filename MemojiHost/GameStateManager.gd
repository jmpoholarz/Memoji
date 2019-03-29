extends Node

var currentRound
var currentState = GAME_STATE.NOT_STARTED
var currentPrompt # Index starting from 0 that refers to the prompt players are currently voting on

var players = [] # array of all players in the game
var audiencePlayers = [] # array of all players in the audience
var totalScoreTally = [] # array of scores for each player, in total
var competitors = [] # players who are competing in the current round of voting

var lobbyCode = null

enum GAME_STATE {
	NOT_STARTED = 0
	PROMPT_PHASE = 1
	VOTE_PHASE = 2
	RESULTS_PHASE = 3
	ROUND_RESULTS = 4
	FINAL_RESULTS = 5
}

func findPlayer(id):
	for p in players:
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
	toTitle()

func on_startGame():
	setupGame()
	currentRound = 1

func setupGame():
	# TODO logic creating enough prompts based on amount of players for this round

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
	
	# Everything ok to start
	currentState = GAME_STATE.PROMPT_PHASE
	$ScreenManager.changeScreenTo(GlobalVars.WAIT_SCREEN)
	$Networking.connect("receivedPlayerAnswer", $ScreenManager.currentScreenInstance.confirmDisplay, "on_prompt_answer")
	$ScreenManager.currentScreenInstance.confirmDisplay.update_from_list(players)
	
	# Create message to send to players that game is starting
	var message = {"messageType":MESSAGE_TYPES.HOST_STARTING_GAME, 
				"letterCode" : lobbyCode}
	# Send message to server
	$Networking.sendMessageToServer(message)
	yield(get_tree().create_timer(1), "timeout")
	
	sendPrompts()

func sendPrompts():
	# Create message dictionary
	var messages_to_send = pair_players(players.size())
	
	print(messages_to_send)
	for m in messages_to_send:
		$Networking.sendMessageToServer(m)
		yield(get_tree().create_timer(1), "timeout")
	
	pass
	
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

func pair_players(numPlayers):
	var messages = []
	var shuffled_players = shufflePlayers(numPlayers)
	print(shuffled_players)
	
	for i in range(numPlayers):
		var prompt = $PromptManager.create_prompt()
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
	"""
	for i in range(numPlayers):
		var prompt = $PromptManager.create_prompt()
		messages.append({
			"messageType":MESSAGE_TYPES.HOST_SENDING_PROMPT,
			"letterCode": lobbyCode,
			"promptID": prompt.get_prompt_id(),
			"prompt": prompt.get_prompt_text(),
			"playerID": players[i % numPlayers].playerID
		})
		messages.append({
			"messageType":MESSAGE_TYPES.HOST_SENDING_PROMPT,
			"letterCode": lobbyCode,
			"promptID": prompt.get_prompt_id(),
			"prompt": prompt.get_prompt_text(),
			"playerID": players[(i + 1) % numPlayers].playerID
		})
	"""
	return messages

func votePhase(): # handle voting for one prompt
	var answers # Array
	var promptID # Integer
	var promptObj
	
	promptID = $PromptManager.active_prompt_ids[currentPrompt]
	answers = $PromptManager.get_answers_to_prompt(promptID)
	promptObj = $PromptManager.active_prompts[promptID]
	
	print("DEBUG: entered votephase")
	currentState = GAME_STATE.VOTE_PHASE
	
	# Change to VotingScreen if not already there and update it
	if ($ScreenManager.currentScreen != GlobalVars.SCREENS.VOTE_SCREEN):
		$ScreenManager.changeScreenTo(GlobalVars.SCREENS.VOTE_SCREEN)
	$ScreenManager.currentScreenInstance.display_emojis(answers[0], answers[1])
	$ScreenManager.currentScreenInstance.display_prompt_text(promptObj.get_prompt_text())
	sendAnswersForVoting(answers)

# Sends the Answers to Players corresponding to the promptID given
func sendAnswersForVoting(answers):
	print("DEBUG: sendAnswersForVoting!!!!")
	var message
	
	for index in range(answers.size()):
		message = {
			"messageType": MESSAGE_TYPES.HOST_SENDING_ANSWERS,
			"letterCode": lobbyCode,
			"answers": answers
		}
		$Networking.sendMessageToServer(message)
		yield(get_tree().create_timer(1), "timeout")

func resultsPhase():
	var promptID = $PromptManager.active_prompt_ids[currentPrompt]
	var competitorIDs = $PromptManager.active_prompts[promptID].get_players_who_answered()
	competitors = []
	for index in range(competitorIDs.size()):
		competitors.append(findPlayer(competitorIDs[index]))
		
	currentState = GAME_STATE.RESULTS_PHASE
	showResults()

func roundResults():
	pass

func showResults():
	# Give IDs of players competing, also calculate array of who voted for what
	var promptID
	var answers
	var currentPlayerVotes = [] # array of which selection was voted for by each players
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
		leftVoters[index] = findPlayer(leftVoterIDs[index])
	for index in range(rightVoterIDs.size()):
		rightVoters[index] = findPlayer(rightVoterIDs[index])
	
	$ScreenManager.changeScreenTo(GlobalVars.RESULTS_SCREEN)
	$ScreenManager.currentScreenInstance.displayAnswers(answers)
	#variables for keeping number of votes and later each calculated player score
	var results1 = $PromptManager.get_votes(promptID, 0)
	var results2 = $PromptManager.get_votes(promptID, 1)
	
	#currentPlayerVotes
	#tally votes for each result
	#for vote in currentPlayerVotes:
	#	if vote == 1:
	#		results1 = results1 + 1
	#	elif vote == 2:
	#		results2 = results2 + 1
	#calculate and display totals of scores
	results1 = $ScreenManager.currentScreenInstance.calculateTotals(1, results1, 0)
	results2 = $ScreenManager.currentScreenInstance.calculateTotals(2, results2, 0)
	#display who voted for each answer
	$ScreenManager.currentScreenInstance.displayVoters(leftVoters, rightVoters)
	#reset votes for next round now that they have been displayed
	#for vote in currentPlayerVotes:
	#	vote = 0
	var pIndex
	for x in range(0,players.size()):
		if competitors[0] == players[x]:
			pIndex = x
	totalScoreTally[pIndex] += results1
	pIndex = 0
	for x in range(0,players.size()):
		if competitors[1] == players[x]:
			pIndex = x
	totalScoreTally[pIndex] += results2

func showTotalResults():
	$ScreenManager.changeScreenTo(GlobalVars.TOTAL_SCREEN)
	$ScreenManager.currentScreenInstance.displayResults(totalScoreTally, players)
	#time till reset
	var t = Timer.new()
	t.setWaitTime(30)
	t.setOneShot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	toTitle()

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
				pass
			pass
	pass

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
	lobbyCode = null
	# TODO Sprint 2: handle currentState, currentRound
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

func _on_Networking_receivedPlayerDetails(playerID, username, avatarIndex):
	# TODO - check that no duplicate username or icon
	for player in players:
		if player.playerID == playerID:
			player.username = username
			player.avatarID = avatarIndex
			
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
		$PromptManager.set_answer(int(promptID), playerID, emojiArray)
		message = {
			"messageType": MESSAGE_TYPES.ACCEPTED_PROMPT_RESPONSE,
			"letterCode": lobbyCode,
			"playerID": playerID
		}
		$Networking.sendMessageToServer(message)

		if ($PromptManager.check_completion()):
			advanceGame()
	
	
func _on_Networking_receivedPlayerVote(playerID, voteID):
	#currentPlayerVotes[playerID] = voteID
	var message
	var promptID
	
	if (currentState == GAME_STATE.VOTE_PHASE):
		promptID = $PromptManager.active_prompt_ids[currentPrompt]
		voteID = int(voteID)
		
		# TODO: Error check
		var temp = $PromptManager.set_vote(promptID, playerID, voteID)
		print("DEBUG: set_vote - ", temp)
		
		message = {
			"messageType": MESSAGE_TYPES.ACCEPTED_VOTE_RESPONSE,
			"letterCode": lobbyCode,
			"playerID": playerID
		}
		$Networking.sendMessageToServer(message)
		
		# Check that all votes are in
		if ($PromptManager.check_votes(promptID, players.size())):
			advanceGame()
		

func _on_Networking_receivedPlayerMultiVote(playerID, promptID, voteArray):
	pass # replace with function body


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
	elif $ScreenManager.currentScreen == GlobalVars.RESULTS_SCREEN:
		if (msg == "advance"):
			advanceGame()
			return
