extends Node

var titleScreenScene = preload("res://TitleScreen.tscn")
var userinfoScreenScene = preload("res://UserInformationScreen.tscn")
var lobbyScreenScene = preload("res://WaitngForGameScreen.tscn")

signal sendMessageToServer(msg)
signal connectToServer()

enum SCREENS {
	TITLE_SCREEN = 1,
	USERINFORMATION_SCREEN = 2,
	LOBBY_SCREEN = 3
	
}

var currentScreen

func _ready():
	pass

func changeScreenTo(screen):
	# TODO - queue_free() before changing screen
	match screen:
		TITLE_SCREEN:
			currentScreen = SCREENS.TITLE_SCREEN
			var TitleScreen = titleScreenScene.instance()
			add_child(TitleScreen)
			TitleScreen.connect("connectToServer", self, "connectToServer")
			TitleScreen.connect("sendMessage", self, "forwardMessage")
			
		USERINFORMATION_SCREEN:
			currentScreen = SCREENS.USERINFORMATION_SCREEN
			var userinfoScreen = userinfoScreenScene.instance()
			add_child(userinfoScreen)
			userinfoScreen.connect("sendMessage", self, "forwardMessage")
		
		LOBBY_SCREEN:
			currentScreen = SCREENS.LOBBY_SCREEN
			var lobbyScreen = lobbyScreenScene.instance()
			add_child(lobbyScreen)
			lobbyScreen.connect("sendMessage", self, "forwardMessage")
			

func forwardMessage(msg):
	print("in forward message with message " + str(msg))
	emit_signal("sendMessageToServer", msg)

func connectToServer():
	print("in ScreenManager connectToServer")
	emit_signal("connectToServer")