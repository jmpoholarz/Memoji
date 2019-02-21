extends Node

var titleScreenScene = preload("res://FirstTitle.tscn")
var lobbyScreenScene = preload("res://LobbyDisplays/LobbyScreen.tscn")
signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1
	SETUP_SCREEN = 2
	LOBBY_SCREEN = 3
}

var currentScreen = 0
var currentScreenNode = null

func _ready():
	pass

# TODO: Free the previous screeen when switching to a different one
func changeScreenTo(screen):
	# TODO - queue_free() before changing scenes
	if (currentScreenNode != null):
		remove_child(currentScreenNode)
		#currentScreenNode.queue_free()
	
	match screen:
		TITLE_SCREEN:
			var titleScreen = titleScreenScene.instance()
			add_child(titleScreen)
			titleScreen.connect("signal", self, "forwardMessage")
			titleScreen.connect("signal", self, "changeScreenTo")			
			currentScreenNode = titleScreen

		LOBBY_SCREEN:
			var lobbyScreen = lobbyScreenScene.instance()
			add_child(lobbyScreen) # disabled for debug
			lobbyScreen.connect("signal", self, "forwardMessage")
			lobbyScreen.connect("signal", self, "changeScreenTo")
			currentScreenNode = lobbyScreen
	
	currentScreen = screen

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)