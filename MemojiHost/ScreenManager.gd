extends Node

var titleScreenScene = preload("res://FirstTitle.tscn")
var lobbyScreenScene = preload("res://LobbyDisplays/LobbyScreen.tscn")
signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1
	SETUP_SCREEN = 2
	LOBBY_SCREEN = 3
}

var currentScreen

func _ready():
	var node = get_node("MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer4/HBoxContainer/ScreenManager")
	this.connect("sendMessageToServer", self, "forwardMessage")


# TODO: Free the previous screeen when switching to a different one
func changeScreenTo(screen):
	# TODO - queue_free() before changing scenes
	match screen:
		TITLE_SCREEN:
			var titleScreen = titleScreenScene.instance()
			add_child(titleScreen)
			#titleScreen.connect("signal", self, "forwardMessage")
		LOBBY_SCREEN:
			var lobbyScreen = lobbyScreenScene.instance()
			add_child(lobbyScreen) # disabled for debug
			lobbyScreen.connect("signal", self, "forwardMessage")
	currentScreen = screen

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)