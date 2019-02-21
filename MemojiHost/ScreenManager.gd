extends Node

var titleScreenScene = preload("res://FirstTitle.tscn")
var lobbyScreenScene = preload("res://LobbyDisplays/LobbyScreen.tscn")
var setupScreenScene = preload("res://Setup.tscn")
signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1
	SETUP_SCREEN = 2
	LOBBY_SCREEN = 3
}

var currentScreen
var currentScreenInstance

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
		SETUP_SCREEN:
			var currentScreenInstance = setupScreenScene.instance()
			add_child(currentScreenInstance)
			currentScreenInstance.connect("sendMessageToServer", self, "forwardMessage")
		LOBBY_SCREEN:
			var currentScreenInstance = lobbyScreenScene.instance()
			add_child(currentScreenInstance) # disabled for debug
			currentScreenInstance.connect("signal", self, "forwardMessage")
	currentScreen = screen

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)