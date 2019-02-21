extends Node

var titleScreenScene = preload("res://FirstTitle.tscn")
var setupScreenScene = preload("res://Setup.tscn")
var lobbyScreenScene = preload("res://LobbyDisplays/LobbyScreen.tscn")
signal sendMessageToServer(msg)
signal handleGameState(msg)			# for GameStateManager

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
	
	currentScreen = screen
	match screen:
		TITLE_SCREEN:
			var titleScreen = titleScreenScene.instance()
			titleScreen.connect("messageServer", self, "forwardMessage")
			titleScreen.connect("changeScreen", self, "changeScreenTo")			
			currentScreenNode = titleScreen
			add_child(titleScreen)
		SETUP_SCREEN:
			var setupScreen = setupScreenScene.instance()
			setupScreen.connect("messageServer", self, "forwardMessage")
			setupScreen.connect("changeScreen", self, "changeScreenTo")			
			setupScreen.connect("updateGameState", self, "forwardGameState")
			currentScreenNode = setupScreen
			add_child(setupScreen)
		LOBBY_SCREEN:
			var lobbyScreen = lobbyScreenScene.instance()
			lobbyScreen.connect("messageServer", self, "forwardMessage")
			lobbyScreen.connect("changeScreen", self, "changeScreenTo")
			lobbyScreen.connect("updateGameState", self, "forwardGameState")
			currentScreenNode = lobbyScreen
			add_child(lobbyScreen)

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)
	
# Allows GUI to communicate with GameStateManager
func forwardGameState(msg):
	print("Hi!!")
	emit_signal("handleGameState", msg)