extends Node

var playerScene = preload("res://Player.tscn") #might not work

var currentRound
var currentState
var player
var lobbyCode
var playerName = name
var playerIcon = 00

func _ready():
	$ScreenManager.changeScreenTo($ScreenManager.TITLE_SCREEN)
	
	$ScreenManager.connect("connectToServer", self, "connectToServer")
	$Networking.connect("_disconnectedFromServer", self, "_on_Networking_connectionTimeout")

func sendAnswer():
	pass

func sendAnswersForVoting():
	pass

func connectToServer():
	#Sprint("in GSM connectToServer")
	$Networking.connectPlayerToServer($Networking.defaultServerIP, $Networking.defaultServerPort)


func _on_Networking_connectionTimeout():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		print("on_Networking_connectionTimeout")
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Could not connect to server.  Connection Timeout.")


func _on_Networking_answersReceived(answerArray):
	pass # replace with function body

func _on_Networking_enteredInvalidAnswer():
#	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		
	pass # replace with function body

func _on_Networking_enteredValidHostCode(playerID, isPlayer, code):
	lobbyCode = code
	player = playerScene.instance() #might not work
	player.playerID = playerID
	player.isPlayer = isPlayer
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.USERINFORMATION_SCREEN)

func _on_Networking_enteredInvalidHostCode():
	#if $ScreenManager.currentScene == $ScreenManager.SCREENS.TITLE_SCREEN:
	#	$ScreenManager/TitleScreen._on_InvalidRoomCode()
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Entered code does not exist.  Check spelling and retry.")

func _on_Networking_enteredInvalidUsername():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager/currentScreenInstance._on_InvalidName()
	pass # replace with function body

func _on_Networking_promptsReceived(promptArray):
	pass # replace with function body


func _on_Networking_enteredValidAnswer():
	pass # replace with function body

func _on_Networking_enteredValidMultiVote():
	pass # replace with function body


func _on_Networking_enteredValidUsername(pName, pIcon):
	playerName = pName
	playerIcon = pIcon
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.SCREENS.LOBBY_SCREEN)
		$ScreenManager.currentScreenInstance.new_room_code(lobbyCode)

func _on_Networking_enteredInvalidMultiVote():
	pass # replace with function body

func _on_Networking_enteredValidVote():
	pass # replace with function body

func _on_Networking_enteredInvalidVote():
	pass # replace with function body

func _on_Networking_forcedToDisconnect():
	pass # replace with function body

func _on_Networking_gameEndedByHost():
	pass # replace with function body

func _on_Networking_gameStartedByHost():
	pass # replace with function body



func _on_ScreenManager_sendMessageToServer(msg):
	print("in GSM with message " + str(msg))
	if player != null:
		msg["playerID"] = player.playerID
	$Networking.sendMessageToServer(msg)


