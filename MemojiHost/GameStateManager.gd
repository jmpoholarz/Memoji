extends Node
const PlayerClass = preload("res://Player.gd")

var playerScene = preload("res://Player.tscn") #might not work

var currentRound
var currentState
var players = []
var audiencePlayers = []

func _ready():
	$ScreenManager.changeScreenTo($ScreenManager.TITLE_SCREEN)
	players = []

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

func _on_Networking_playerConnected(playerID, isPlayer):
	# Add new player to players array
	player = playerScene.instance() #might not work
	player.playerID = playerID
	player.isPlayer = isPlayer
	players.append(player)

func _on_Networking_playerDisconnected(playerID):
	# Remove player from array
	for player in players:
		if player.playerID == playerID:
			players.remove(player)

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
