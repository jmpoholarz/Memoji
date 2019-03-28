extends Node

var currentRound
var currentState = GAME_STATE.NOT_STARTED
var currentPrompt # Index starting from 0 that refers to the prompt players are currently voting on
var answers = []

var players = []
var audiencePlayers = []
var currentPlayerVotes = []
var totalScoreTally = []
var competitors = [] # players who are competing in the current round of voting

var lobbyCode = null

enum GAME_STATE {
	NOT_STARTED = 0
	PROMPT_PHASE = 1
	VOTE_PHASE = 2
}

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
	
	# Create message to send to players that game is starting
	var message = {"messageType":MESSAGE_TYPES.HOST_STARTING_GAME, 
				"letterCode" : lobbyCode}
	# Send message to server
	$Networking.sendMessageToServer(message)
	yield(get_tree().create_timer(1), "timeout")
	
	sendPrompts()

func sendPrompts():
	# Get prompts -> PromptManager, PromptGenerator
	var numPrompts = 0
	var messages_to_send = []
	var numPlayers = players.size()
	
	match (numPlayers):
		3:
			numPrompts = GlobalVars.three_players
		4:
			numPrompts = GlobalVars.four_players
	
	# Create message dictionary
	for i in range(3):
		var prompt = $PromptManager.create_prompt()
		messages_to_send.append({
			"messageType":MESSAGE_TYPES.HOST_SENDING_PROMPT,
			"letterCode": lobbyCode,
			"promptID": prompt.get_prompt_id(),
			"prompt": prompt.get_prompt_text(),
			"playerID": players[i % numPlayers].playerID
		})
		messages_to_send.append({
			"messageType":MESSAGE_TYPES.HOST_SENDING_PROMPT,
			"letterCode": lobbyCode,
			"promptID": prompt.get_prompt_id(),
			"prompt": prompt.get_prompt_text(),
			"playerID": players[(i + 1) % numPlayers].playerID
		})
	
	print(messages_to_send)
	for m in messages_to_send:
		$Networking.sendMessageToServer(m)
		yield(get_tree().create_timer(1), "timeout")
	
	pass

func votePhase(): # handle voting for one prompt
	# Screen
	currentState = GAME_STATE.VOTE_PHASE
	
	if ($ScreenManager.currentScreen != GlobalVars.SCREENS.VOTE_SCREEN):
		$ScreenManager.changeScreenTo(GlobalVars.SCREENS.VOTE_SCREEN)
	else:
		pass
		# TODO: Reset the voting screen to display current prompt
		#$ScreenManager.currentScreenInstance.reset_display()
	
	sendAnswersForVoting($PromptManager.active_prompt_ids[currentPrompt])

# Sends the Answers to Players corresponding to the promptID given
func sendAnswersForVoting(promptID):
	var answers = []
	var message
	answers = $PromptManager.get_answers_to_prompt(promptID)
	
	for index in range(answers.size()):
		message = {
			"messageType": MESSAGE_TYPES.HOST_SENDING_ANSWERS,
			"letterCode": lobbyCode,
			"answers": answers
		}
		$Networking.sendMessageToServer(message)
		yield(get_tree().create_timer(1), "timeout")

func showResults():
	$ScreenManager.changeScreenTo(GlobalVars.RESULTS_SCREEN)
	#variables for keeping number of votes and later each calculated player score
	var results1 = 0
	var results2 = 0
	#tally votes for each result
	for vote in currentPlayerVotes:
		if vote == 1:
			results1 = results1 + 1
		elif vote == 2:
			results2 = results2 + 1
	#calculate and display totals of scores
	results1 = $ScreenManager.currentScreenInstance.calculateTotals(1, results1, 0)
	results2 = $ScreenManager.currentScreenInstance.calculateTotals(2, results2, 0)
	#display who voted for each answer
	$ScreenManager.currentScreenInstance.displayVoters(currentPlayerVotes, players)
	#reset votes for next round now that they have been displayed
	for vote in currentPlayerVotes:
		vote = 0

func advanceGame():
	match (currentState):
		GAME_STATE.PROMPT_PHASE:
			votePhase()
		GAME_STATE.VOTE_PHASE:
			# TODO: check if last round of voting, then continue to final prompt
			
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
		currentPlayerVotes.append(0)
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
<<<<<<< HEAD
	# TODO: find corresponding prompt and add the player's answer to it
	#for prompt in prompts:
	#	if (promptID == prompt.promptID):
	#		prompt.insertAnswer(playerID, emojiArray)
	
	return
=======
	# TODO: Check for where in the game we currently arer
	# i.e. if the current screen is on waiting
	if (currentState == GAME_STATE.PROMPT_PHASE):
		
		$PromptManager.set_answer(promptID, playerID, emojiArray)
		if ($PromptManager.check_completion()):
			currentState = GAME_STATE.VOTE_PHASE
			advanceGame()
>>>>>>> e77a4b85622324065309a199ff2c2b234f4f9a93

func _on_Networking_receivedPlayerVote(playerID, promptID, voteID):
	currentPlayerVotes[playerID] = voteID

func _on_Networking_receivedPlayerMultiVote(playerID, promptID, voteArray):
	pass # replace with function body


func _on_ScreenManager_sendMessageToServer(msg):
	print("DEBUG MESSAGE: Message Sending")
	$Networking.sendMessageToServer(msg)


func _on_ScreenManager_handleGameState(msg):
	if $ScreenManager.currentScreen == GlobalVars.LOBBY_SCREEN:
		if (msg == "code" && lobbyCode != null):
			$ScreenManager.currentScreenInstance.update_lettercode(lobbyCode)
		elif (msg == "disconnectLobby"):
			toTitle()
