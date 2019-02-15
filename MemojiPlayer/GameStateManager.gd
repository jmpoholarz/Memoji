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

func _on_Networking_enteredValidHostCode():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.changeScreenTo(USERINFORMATION_SCREEN)
	
	pass # replace with function body

func _on_Networking_enteredInvalidHostCode():
#	$ScreenManager.currentScene
	pass # replace with function body

func _on_Networking_enteredInvalidMultiVote():
	pass # replace with function body

func _on_Networking_enteredInvalidUsername():
	pass # replace with function body

func _on_Networking_enteredInvalidVote():
	pass # replace with function body

func _on_Networking_enteredValidAnswer():
	pass # replace with function body

func _on_Networking_enteredValidMultiVote():
	pass # replace with function body

func _on_Networking_enteredValidUsername():
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
	$Networking.sendMessageToServer(msg)


