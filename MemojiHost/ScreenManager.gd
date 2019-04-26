extends Node

var titleScreenScene = preload("res://Screens/FirstTitle.tscn")
var setupScreenScene = preload("res://Screens/Setup.tscn")
var lobbyScreenScene = preload("res://Screens/LobbyDisplays/LobbyScreen.tscn")

var waitScreenScene = preload("res://Screens/WaitScreen.tscn")
var voteScreenScene = preload("res://Screens/VotingScreen.tscn")

var resultsScreenScene = preload("res://Screens/HostResultsScreen.tscn")
var totalResultsScreenScene = preload("res://Screens/HostTotalResultsScreen.tscn")

var multiVoteScreenScene = preload("res://Screens/MultiVotingScreen.tscn")
var multiResultsScreenScene = preload("res://Screens/HostFinalRoundResultScreen.tscn")
var creditsScene = preload("res://Screens/InstructionScreens/Credits.tscn")

#instruction screens
var initialInstruction = preload("res://Screens/InstructionScreens/InitialInstruction.tscn") # check
var promptInstruction = preload("res://Screens/InstructionScreens/PromptInstruction.tscn") # check
var votingInstruction = preload("res://Screens/InstructionScreens/VotingInstruction.tscn") # check
var scoringInstruction = preload("res://Screens/InstructionScreens/ScoringInstruction.tscn") # check
var finalInstruction = preload("res://Screens/InstructionScreens/FinalRoundInstruction.tscn")


signal connectToServer()
signal sendMessageToServer(msg)
signal handleGameState(msg)			# for GameStateManager

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
			onInstructionScreen = false
			currentScreenInstance = lobbyScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.WAIT_SCREEN:
			onInstructionScreen = false
			currentScreenInstance = waitScreenScene.instance()
		GlobalVars.VOTE_SCREEN:
			onInstructionScreen = false
			currentScreenInstance = voteScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.RESULTS_SCREEN:
			onInstructionScreen = false
			currentScreenInstance = resultsScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.TOTAL_SCREEN:
			currentScreenInstance = totalResultsScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.MULTI_VOTE_SCREEN:
			currentScreenInstance = multiVoteScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.MULTI_RESULTS_SCREEN:
			currentScreenInstance = multiResultsScreenScene.instance()
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.CREDITS_SCREEN:
			if(!repeatInstruct):
				instructions = false
			currentScreenInstance = creditsScene.instance()
			currentScreenInstance.connect("restart", self, "restartGame")
			currentScreenInstance.connect("newGame", self, "newGame")
		
		GlobalVars.INITIAL_INSTRUCTION:
			currentScreenInstance = initialInstruction.instance()
			onInstructionScreen = true
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.PROMPT_INSTRUCTION:
			currentScreenInstance = promptInstruction.instance()
			onInstructionScreen = true
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.VOTING_INSTRUCTION:
			currentScreenInstance = votingInstruction.instance()
			onInstructionScreen = true
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.SCORING_INSTRUCTION:
			currentScreenInstance = scoringInstruction.instance()
			onInstructionScreen = true
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
		GlobalVars.FINAL_INSTRUCTION:
			currentScreenInstance = finalInstruction.instance()
			onInstructionScreen = true
			currentScreenInstance.connect("updateGameState", self, "forwardGameState")
			
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