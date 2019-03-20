extends Node

var currentRound
var currentState
var players = []
var audiencePlayers = []

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
	
	toTitle()

func setupGame():
	# TODO logic creating enough prompts based on amount of players for this round
	pass

func sendPrompts():
	#
	pass

func sendAnswersForVoting():
	pass

func showResults():
	$ScreenManager.changeScreenTo(GlobalVars.RESULTS_SCREEN)

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
	for prompt in prompts:
		if (promptID == prompt.promptID):
			prompt.insertAnswer(playerID, emojiArray)
	
	return

func _on_Networking_receivedPlayerVote(playerID, promptID, voteID):
	pass # replace with function body

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
