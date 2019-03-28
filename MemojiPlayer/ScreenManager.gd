extends Node

var titleScreenScene = preload("res://TitleScreen.tscn")
var userinfoScreenScene = preload("res://UserInformationScreen.tscn")
var playerVotingScene = preload("res://PlayerVoting.tscn")
var lobbyScreenScene = preload("res://Screens/WaitingForGameStartScreen.tscn")
var prompt_answering_screen_scene = preload("res://Screens/PlayerPromptScreen.tscn")
var wait_screen = preload("res://Screens/WaitingScreen.tscn")
var playerWaitingAfterVotingScreen = preload("res://WaitingAfterVotingScreen.tscn")

signal sendMessageToServer(msg)
signal connectToServer()
signal disconnectFromServer()
signal screen_change_completed()

enum SCREENS {
	TITLE_SCREEN = 1,
	USERINFORMATION_SCREEN = 2,
	LOBBY_SCREEN = 3,
	WAITING_SCREEN = 4,
	PROMPT_ANSWERING_SCREEN = 5,
	PLAYER_VOTING_SCREEN = 6,
	PLAYER_WAITING_AFTER_VOTING_SCREEN = 7
	
}

var currentScreen
var currentScreenInstance

func _ready():
	pass

func changeScreenTo(screen):
	# TODO - queue_free() before changing screen
	match screen:
		TITLE_SCREEN:
			currentScreenInstance = titleScreenScene.instance()
			add_child(currentScreenInstance)
			currentScreenInstance.connect("connectToServer", self, "connectToServer")
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			
		USERINFORMATION_SCREEN:
			currentScreenInstance = userinfoScreenScene.instance()
			add_child(currentScreenInstance)
			#currentScreenInstance.connect("connectToServer", self, "connectToServer")
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			var GSM = get_node("../")
			currentScreenInstance.change_name_and_icon(GSM.playerName, GSM.playerIcon)
		
		LOBBY_SCREEN:
			currentScreenInstance = lobbyScreenScene.instance()
			add_child(currentScreenInstance)
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			currentScreenInstance.connect("changeScreen", self, "changeScreenTo")
			currentScreenInstance.connect("disconnectFromHost", self, "disconnectFromServer")
		
		PLAYER_VOTING_SCREEN:
			currentScreenInstance = playerVotingScene.instance()
			add_child(currentScreenInstance)
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			currentScreenInstance.connect("change_screen", self, "changeScreenTo")
			
		PROMPT_ANSWERING_SCREEN:
			currentScreenInstance = prompt_answering_screen_scene.instance()
			add_child(currentScreenInstance)
			currentScreenInstance.connect("send_message", self, "forwardMessage")
			currentScreenInstance.connect("out_of_prompts", self, "go_to_waiting_screen")
			
		WAITING_SCREEN:
			currentScreenInstance = wait_screen.instance()
			add_child(currentScreenInstance)
			
		
		PLAYER_WAITING_AFTER_VOTING_SCREEN:
			currentScreenInstance = wait_screen.instance()
			add_child(currentScreenInstance)
		
	currentScreen = screen
	emit_signal("screen_change_completed")

func forwardMessage(msg):
	#print("in forward message with message " + str(msg))
	emit_signal("sendMessageToServer", msg)

func connectToServer():
	#print("in ScreenManager connectToServer")
	emit_signal("connectToServer")

func disconnectFromServer():
	emit_signal("disconnectFromServer")

func go_to_waiting_screen():
	changeScreenTo(SCREENS.WAITING_SCREEN)