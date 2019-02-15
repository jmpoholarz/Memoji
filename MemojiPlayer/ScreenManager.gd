extends Node

signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1
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
			

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)