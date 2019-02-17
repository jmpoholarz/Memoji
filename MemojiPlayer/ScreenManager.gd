extends Node

var titleScreenScene = preload("res://TitleScreen.tscn")
var userinfoScreenScene = preload("res://UserInformationScreen.tscn")
var lobbyScreenScene = preload("res://WaitngForGameScreen.tscn")

signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1,
	USERINFORMATION_SCREEN = 2,
	LOBBY_SCREEN = 3
	
}

var currentScreen

func _ready():
	pass

func changeScreenTo(screen):
	match screen:
		TITLE_SCREEN:
			var titleScreen = titleScreenScene.instance()
			add_child(titleScreen)
			titleScreen.connect("sendMessage", self, "forwardMessage")
			
		USERINFORMATION_SCREEN:
			var userinfoScreen = userinfoScreenScene.instance()
			add_child(userinfoScreen)
			userinfoScreen.connect("sendMessage", self, "forwardMessage")
		
		LOBBY_SCREEN:
			var lobbyScreen = lobbyScreenScene.instance()
			add_child(lobbyScreen)
			lobbyScreen.connect("sendMessage", self, "forwardMessage")
			

func forwardMessage(msg):
	print("in forward message with message " + str(msg))
	emit_signal("sendMessageToServer", msg)