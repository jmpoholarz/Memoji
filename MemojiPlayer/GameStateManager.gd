extends Node

var playerScene = preload("res://Player.tscn") #might not work

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
	pass # replace with function body

func _on_Networking_enteredValidHostCode(playerID, isPlayer):
	player = playerScene.instance() #might not work
	player.playerID = playerID
	player.isPlayer = isPlayer

func _on_Networking_enteredInvalidHostCode():
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
	if player != null:
		msg["playerID"] = player.playerID
	$Networking.sendMessageToServer(msg)


