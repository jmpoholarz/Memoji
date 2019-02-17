extends Node

var currentRound
var currentState
var player

func _ready():
	$ScreenManager.changeScreenTo($ScreenManager.TITLE_SCREEN)

func sendAnswer():
	pass

func sendAnswersForVoting():
	pass



func _on_Networking_answersReceived(answerArray):
	pass # replace with function body

func _on_Networking_enteredInvalidAnswer():
#	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		
	pass # replace with function body

func _on_Networking_enteredValidHostCode(playerID, isPlayer):
	var playerScene = load("res://Player.tscn") #might not work
	player = playerScene.instance() #might not work
	player.playerID = playerID
	player.isPlayer = isPlayer
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.changeScreenTo(USERINFORMATION_SCREEN)

func _on_Networking_enteredInvalidHostCode():
	if $ScreenManager.currentScene == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager/TitleScreen._on_InvalidRoomCode()
	pass # replace with function body

func _on_Networking_enteredInvalidMultiVote():
	pass # replace with function body

func _on_Networking_enteredInvalidUsername():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager/UserInformationPanel._on_InvalidName()
	pass # replace with function body

func _on_Networking_enteredInvalidVote():
	pass # replace with function body

func _on_Networking_enteredValidAnswer():
	pass # replace with function body

func _on_Networking_enteredValidMultiVote():
	pass # replace with function body

func _on_Networking_enteredValidUsername():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager.changeScreenTo(LOBBY_SCREEN)
	pass # replace with function body

func _on_Networking_enteredValidVote():
	pass # replace with function body

func _on_Networking_forcedToDisconnect():
	pass # replace with function body

func _on_Networking_gameEndedByHost():
	pass # replace with function body

func _on_Networking_gameStartedByHost():
	pass # replace with function body

func _on_Networking_promptsReceived(promptArray):
	pass # replace with function body



func _on_ScreenManager_sendMessageToServer(msg):
	if player != null:
		msg["playerID"] = player.playerID
	$Networking.sendMessageToServer(msg)


