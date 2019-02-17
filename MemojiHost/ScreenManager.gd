extends Node

var titleScreen = preload("res://FirstTitle.tscn")

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
			add_child(titleScreen.instance())
			#titleScreen.connect("signal", self, "forwardMessage")

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)