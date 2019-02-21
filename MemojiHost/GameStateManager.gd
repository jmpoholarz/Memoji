extends Node

const PlayerClass = preload("res://Player.gd")

var currentRound
var currentState
var players = []
var audiencePlayers = []

var lobbyCode = null

func debug_to_lobby():
	$ScreenManager.changeScreenTo($ScreenManager.LOBBY_SCREEN)
	
	var request = { "messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE, "letterCode": "????" }
	_on_ScreenManager_sendMessageToServer(request)
	
func _ready():
	
	$ScreenManager.changeScreenTo($ScreenManager.TITLE_SCREEN)
	
	players = []
	
	#debug_to_lobby()

func setupGame():
	pass

func sendPrompts():
	pass

func sendAnswersForVoting():
	pass

func showResults():
	pass

func advanceGame():
	pass

func quitHosting():
	pass



func _on_Networking_obtainedLetterCode(letterCode):
	lobbyCode = letterCode
	
	if ($ScreenManager.currentScreen == $ScreenManager.SETUP_SCREEN):
		$ScreenManager.currentScreenInstance.update_lettercode(letterCode)
		pass
	elif ($ScreenManager.currentScreen == $ScreenManager.LOBBY_SCREEN):
		$ScreenManager.currentScreenInstance.update_lettercode(letterCode)
		pass

func _on_Networking_playerConnected(playerID, isPlayer):
	# Add new player to players array
	var player
	player = PlayerClass.new()
	player.playerID = playerID
	player.isPlayer = isPlayer
	players.append(player)
	
	if ($ScreenManager.currentScreen == $ScreenManager.LOBBY_SCREEN):
		# TODO: Update the lobby screen's player displays
		$ScreenManager.currentScreenInstance.add_player_id(playerID)

func _on_Networking_playerDisconnected(playerID):
	# Remove player from array
	for player in players:
		if player.playerID == playerID:
			players.remove(player)
			if ($ScreenManager.currentScreen == $ScreenManager.LOBBY_SCREEN):
				pass # TODO: update the lobby screen's info
			

func _on_Networking_receivedPlayerDetails(playerID, username, avatarIndex):
	for player in players:
		if player.playerID == playerID:
			player.username = username
			player.avatarID = avatarIndex
			
			if ($ScreenManager.currentScreen == $ScreenManager.LOBBY_SCREEN):
				$ScreenManagercurrentScreenInstance.update_player_status(player)
	
	pass # replace with function body

func _on_Networking_receivedPlayerAnswer(playerID, promptID, emojiArray):
	pass # replace with function body

func _on_Networking_receivedPlayerVote(playerID, promptID, voteID):
	pass # replace with function body

func _on_Networking_receivedPlayerMultiVote(playerID, promptID, voteArray):
	pass # replace with function body


func _on_ScreenManager_sendMessageToServer(msg):
	print("DEBUG MESSAGE: Message Sending")
	$Networking.sendMessageToServer(msg)


func _on_ScreenManager_handleGameState(msg):
	print("Hey!")
	if $ScreenManager.currentScreen == $ScreenManager.LOBBY_SCREEN:
		if (msg == "code" && lobbyCode != null):
			$ScreenManager/LobbyScreen.update_lettercode(lobbyCode)
			pass

