extends Node

var titleScreenScene = preload("res://Screens/TitleScreen.tscn")
var userinfoScreenScene = preload("res://Screens/UserInformationScreen.tscn")
var playerVotingScene = preload("res://PlayerVoting.tscn")
var lobbyScreenScene = preload("res://Screens/WaitingForGameStartScreen.tscn")
var prompt_answering_screen_scene = preload("res://Screens/PlayerPromptScreen.tscn")
var wait_screen = preload("res://Screens/WaitingScreen.tscn")
var playerWaitingAfterVotingScreen = preload("res://WaitingAfterVotingScreen.tscn")
var finalVotingScreen = preload("res://FinalVotingScreen.tscn")

signal sendMessageToServer(msg)
signal connectToServer()
signal disconnectFromServer()
signal screen_change_completed()
signal updateGameState(newState)
signal updateLetterCode(letter_code)

enum SCREENS {
	TITLE_SCREEN = 1,
	USERINFORMATION_SCREEN = 2,
	LOBBY_SCREEN = 3,
	WAITING_SCREEN = 4,
	PROMPT_ANSWERING_SCREEN = 5,
	PLAYER_VOTING_SCREEN = 6,
	PLAYER_WAITING_AFTER_VOTING_SCREEN = 7,
	FINAL_VOTING_SCREEN = 8
	
}

enum GAME_STATE {
	NOT_STARTED = 0
	PROMPT_PHASE = 1
	VOTE_PHASE = 2
	RESULTS_PHASE = 3
	ROUND_RESULTS = 4
	FINAL_RESULTS = 5
}

onready var _LostConnectionPopup = $LostConnectionPopup

var currentScreen = -1
var currentScreenInstance = null

func _ready():
	pass

func changeScreenTo(screen):
	if (currentScreenInstance != null):
		remove_child(currentScreenInstance)
		currentScreenInstance.queue_free()
		currentScreenInstance = null
	
	var currentState
	
	match screen:
		TITLE_SCREEN:
			currentScreenInstance = titleScreenScene.instance()
			currentScreenInstance.connect("connectToServer", self, "connectToServer")
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			currentScreenInstance.connect("updateLetterCode", self, "updateLetterCode")
			currentState = GAME_STATE.NOT_STARTED
			
		USERINFORMATION_SCREEN:
			currentScreenInstance = userinfoScreenScene.instance()
			#currentScreenInstance.connect("connectToServer", self, "connectToServer")
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			var GSM = get_parent() #this probably shouldn't be allowed
			currentScreenInstance.username = GSM.playerName
			currentScreenInstance.avatar_id = GSM.playerIcon
			currentState = GAME_STATE.NOT_STARTED
		
		LOBBY_SCREEN:
			currentScreenInstance = lobbyScreenScene.instance()
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			currentScreenInstance.connect("changeScreen", self, "changeScreenTo")
			currentScreenInstance.connect("disconnectFromHost", self, "disconnectFromServer")
			currentState = GAME_STATE.NOT_STARTED
		
		PLAYER_VOTING_SCREEN:
			currentScreenInstance = playerVotingScene.instance()
			currentScreenInstance.connect("send_message", self, "forwardMessage")
			currentScreenInstance.connect("change_screen", self, "changeScreenTo")
			currentState = GAME_STATE.VOTE_PHASE
			
		PROMPT_ANSWERING_SCREEN:
			currentScreenInstance = prompt_answering_screen_scene.instance()
			currentScreenInstance.connect("send_message", self, "forwardMessage")
			currentScreenInstance.connect("out_of_prompts", self, "go_to_waiting_screen")
			currentState = GAME_STATE.PROMPT_PHASE
			
		WAITING_SCREEN:
			currentScreenInstance = wait_screen.instance()
		
		PLAYER_WAITING_AFTER_VOTING_SCREEN:
			currentScreenInstance = wait_screen.instance()
		
		FINAL_VOTING_SCREEN:
			currentScreenInstance = finalVotingScreen.instance()
			currentScreenInstance.connect("send_message", self, "forwardMessage")
			currentScreenInstance.connect("change_screen", self, "changeScreenTo")
			

	currentScreen = screen
	add_child(currentScreenInstance)
	emit_signal("screen_change_completed")
	emit_signal("updateGameState", currentState)

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)

func connectToServer():
	emit_signal("connectToServer")

func disconnectFromServer():
	emit_signal("disconnectFromServer")

func go_to_waiting_screen():
	changeScreenTo(SCREENS.WAITING_SCREEN)

func lost_connection():
	_LostConnectionPopup.popup()

func updateLetterCode(letter_code):
	emit_signal("updateLetterCode", letter_code)