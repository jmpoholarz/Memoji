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

var currentScreen
var currentScreenInstance

func _ready():
	pass


# TODO: Free the previous screeen when switching to a different one
func changeScreenTo(screen):
	# TODO - queue_free() before changing scenes
	if (currentScreenInstance != null):
		remove_child(currentScreenInstance)
		currentScreenInstance.queue_free()
	
	currentScreenInstance == null
	currentScreen = screen
	match screen:
		TITLE_SCREEN:
			currentScreenInstance = titleScreenScene.instance()
		SETUP_SCREEN:
			currentScreenInstance = setupScreenScene.instance()
		LOBBY_SCREEN:
			currentScreenInstance = lobbyScreenScene.instance()
	
	if (currentScreenInstance != null):
		currentScreenInstance.connect("messageServer", self, "forwardMessage")
		currentScreenInstance.connect("changeScreen", self, "changeScreenTo")
		currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		add_child(currentScreenInstance)

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)
	
# Allows GUI to communicate with GameStateManager
func forwardGameState(msg):
	print("Hi!!")
	emit_signal("handleGameState", msg)
