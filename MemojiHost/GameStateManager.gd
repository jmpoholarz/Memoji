extends Node

var currentRound
var currentState
var players
var audiencePlayers

func _ready():
	$ScreenManager.changeScreenTo($ScreenManager.TITLE_SCREEN)

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
	pass # replace with function body

func _on_Networking_playerConnected(playerID):
	pass # replace with function body

func _on_Networking_playerDisconnected(playerID):
	pass # replace with function body

func _on_Networking_receivedPlayerAnswer(playerID, promptID, emojiArray):
	pass # replace with function body

func _on_Networking_receivedPlayerDetails(playerID, username, avatarIndex):
	pass # replace with function body

func _on_Networking_receivedPlayerMultiVote(playerID, promptID, voteArray):
	pass # replace with function body

func _on_Networking_receivedPlayerVote(playerID, promptID, voteID):
	pass # replace with function body



func _on_ScreenManager_sendMessageToServer(msg):
	$Networking.sendMessageToServer(msg)
