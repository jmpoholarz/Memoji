extends Node

var titleScreenScene = preload("res://Screens/FirstTitle.tscn")
var setupScreenScene = preload("res://Screens/Setup.tscn")
var lobbyScreenScene = preload("res://Screens/LobbyDisplays/LobbyScreen.tscn")

var waitScreenScene = preload("res://Screens/WaitScreen.tscn")
var voteScreenScene = preload("res://Screens/VotingScreen.tscn")

var resultsScreenScene = preload("res://Screens/HostResultsScreen.tscn")
var totalResultsScreenScene = preload("res://Screens/HostTotalResultsScreen.tscn")

var creditsScene = preload("res://Screens/InstructionScreens/Credits.tscn")

#instruction screens
var initialInstruction = preload("res://Screens/InstructionScreens/InitialInstruction.tscn")

signal connectToServer()
signal sendMessageToServer(msg)
signal handleGameState(msg)			# for GameStateManager
signal startGame()
signal restart()
signal newGame()
signal instructionUpdate(instruct, repeat)

onready var _LostConnectionPopup = $LostConectionPopup

var currentScreen
var currentScreenInstance

var instructions = true # whether or not to show instructions before the actual game begins
var repeatInstruct = false # whether to show instructions for every round of the game
var onInstructionScreen = false # whether the game is currently on an instruction screen

func _ready():
	pass


# TODO: Free the previous screeen when switching to a different one
func changeScreenTo(screen):
	# TODO - queue_free() before changing scenes
	if (currentScreenInstance != null):
		if(currentScreen == GlobalVars.SETUP_SCREEN):
			instructionState()
		remove_child(currentScreenInstance)
		currentScreenInstance.queue_free()
		currentScreenInstance = null
		currentScreen = null
	
	match screen:
		GlobalVars.TITLE_SCREEN:
			currentScreenInstance = titleScreenScene.instance()
			currentScreenInstance.connect("connectToServer", self, "connectToServer")
		GlobalVars.SETUP_SCREEN:
			currentScreenInstance = setupScreenScene.instance()
		GlobalVars.LOBBY_SCREEN:
			currentScreenInstance = lobbyScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
			currentScreenInstance.connect("startGame", self, "startGame")
		GlobalVars.WAIT_SCREEN:
			currentScreenInstance = waitScreenScene.instance()
		GlobalVars.VOTE_SCREEN:
			currentScreenInstance = voteScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.RESULTS_SCREEN:
			currentScreenInstance = resultsScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.TOTAL_SCREEN:
			currentScreenInstance = totalResultsScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.CREDITS_SCREEN:
			currentScreenInstance = creditsScene.instance()
			currentScreenInstance.connect("restart", self, "restartGame")
			currentScreenInstance.connect("newGame", self, "newGame")
	
	if (currentScreenInstance != null):
		currentScreen = screen
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

func lost_connection():
	_LostConnectionPopup.popup()

func restartGame():
	emit_signal("restart")

func newGame():
	emit_signal("newGame")

func instructionState():
	instructions = currentScreenInstance.getInstructionState()
	repeatInstruct = currentScreenInstance.getInstructionState()
	emit_signal("instructionUpdate", instructions, repeatInstruct)