extends Node

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
			var titleScreen = load("res://TitleScreen.tscn")
			add_child(titleScreen.instance())
			titleScreen.connect("sendMessage", self, "forwardMessage")
			
		USERINFORMATION_SCREEN:
			var userinfoScreen = load("res://UserInformationScreen.tscn")
			add_child(userinfoScreen.instance())
			userinfoScreen.connect("sendMessage", self, "forwardMessage")
		
		LOBBY_SCREEN:
			var lobbyScreen = load("res://WaitngForGameScreen.tscn")
			add_child(lobbyScreen.instance())
			lobbyScreen.connect("sendMessage", self, "forwardMessage")
			

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)