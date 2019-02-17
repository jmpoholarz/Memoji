extends Node

var titleScreenScene = preload("res://FirstTitle.tscn")

signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1
	SETUP_SCREEN = 2
	LOBBY_SCREEN = 3
}

var currentScreen

func _ready():
	pass

# TODO: Free the previous screeen when switching to a different one
func changeScreenTo(screen):
	# TODO - queue_free() before changing scenes
	match screen:
		TITLE_SCREEN:
			var titleScreen = titleScreenScene.instance()
			add_child(titleScreen)
			#titleScreen.connect("signal", self, "forwardMessage")
		LOBBY_SCREEN:
			var lobbyScreen = load("res://LobbyDisplays/LobbyScreen.tscn")

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)