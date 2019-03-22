extends Node

var currentRound
var currentState
var players = []
var audiencePlayers = []
var currentPlayerVotes = []
var totalScoreTally = []

#var prompts = [] # Handled in PromptManager child

var lobbyCode = null

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

func setupGame():
	# TODO logic creating enough prompts based on amount of players for this round

	# Check for if there are enough players joined
	var numPlayers = players.length()
	if numPlayers <= 2:
		# Not enough players are joined
		print("Not enough players joined")
		return
	# Check for players are connected but no avatar is selected
	for player in players:
		if player.avatarID == null || player.username == null:
			# Not all players have an avatar selected
			print("Not all players have username/avatar")
			return
	
	# Create message to send to players that game is starting
	var message = {"messageType":MESSAGE_TYPES.HOST_STARTING_GAME, 
				"letterCode" : lobbyCode}
	# Send message to server
	$Networking.sendMessageToServer(message)
	
	# Get prompts -> PromptManager, PromptGenerator
	var numPrompts = 0
#	if numPlayers == 3:
#		numPrompts = GlobalVars
		
	var prompts_to_send = []
	for i in range(numPrompts):
		prompts_to_send.append($PromptManager._get_new_prompt())
	# Create message dictionary
	
	$ScreenManager.changeScreenTo(GlobalVars.WAIT_SCREEN)


func sendPrompts():
	#
	pass

func sendAnswersForVoting():
	pass

func showResults():
	$ScreenManager.changeScreenTo(GlobalVars.RESULTS_SCREEN)
	var results1 = 0
	var results2 = 0
	for vote in currentPlayerVotes:
		if vote == 1:
			results1 = results1 + 1
		elif vote == 2:
			results2 = results2 + 1
	results1 = $ScreenManager.currentScreenInstance.calculateTotals(1, results1, 0)
	results2 = $ScreenManager.currentScreenInstance.calculateTotals(2, results2, 0)
	$ScreenManager.currentScreenInstance.displayVoters(currentPlayerVotes)
	for vote in currentPlayerVotes:
		vote = 0
	#TODO totalScoreTally[idOfEachVotedPlayer] += total calculated score

func advanceGame():
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
	# TODO: find corresponding prompt and add the player's answer to it
	#for prompt in prompts:
	#	if (promptID == prompt.promptID):
	#		prompt.insertAnswer(playerID, emojiArray)
	
	return

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
