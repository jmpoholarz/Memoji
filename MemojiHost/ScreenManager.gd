extends Node

var titleScreenScene = preload("res://Screens/FirstTitle.tscn")
var setupScreenScene = preload("res://Screens/Setup.tscn")
var lobbyScreenScene = preload("res://Screens/LobbyDisplays/LobbyScreen.tscn")
#var waitScreenScene = preload("res://Screens/WaitScreen.tscn")
var resultsScreenScene = preload("res://Screens/HostResultsScreen.tscn")
var totalResultsScreenScene = preload("res://Screens/HostTotalResultsScreen.tscn")

signal connectToServer()
signal sendMessageToServer(msg)
signal handleGameState(msg)			# for GameStateManager
signal startGame()

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
		GlobalVars.TITLE_SCREEN:
			currentScreenInstance = titleScreenScene.instance()
			currentScreenInstance.connect("connectToServer", self, "connectToServer")
		GlobalVars.SETUP_SCREEN:
			currentScreenInstance = setupScreenScene.instance()
		GlobalVars.LOBBY_SCREEN:
			currentScreenInstance = lobbyScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
<<<<<<< HEAD
		
=======
			currentScreenInstance.connect("startGame", self, "startGame")
		GlobalVars.WAIT_SCREEN:
			currentScreenInstance = waitScreenScene.instance()
>>>>>>> e77a4b85622324065309a199ff2c2b234f4f9a93
		GlobalVars.RESULTS_SCREEN:
			currentScreenInstance = resultsScreenScene.instance()
		GlobalVars.TOTAL_SCREEN:
			currentScreenInstance = resultsScreenScene.instance()
	
	if (currentScreenInstance != null):
		currentScreenInstance.connect("messageServer", self, "forwardMessage")
		currentScreenInstance.connect("changeScreen", self, "changeScreenTo")
		add_child(currentScreenInstance)


func connectToServer():
	emit_signal("connectToServer")

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)
	
# Allows GUI to communicate with GameStateManager
func forwardGameState(msg):
	emit_signal("handleGameState", msg)

func startGame():
	emit_signal("startGame")
