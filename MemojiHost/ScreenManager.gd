extends Node

var titleScreenScene = preload("res://FirstTitle.tscn")

signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1
}

var currentScreen

func _ready():
	pass

func changeScreenTo(screen):
	# TODO - queue_free() before changing scenes
	match screen:
		TITLE_SCREEN:
			var titleScreen = titleScreenScene.instance()
			add_child(titleScreen)
			#titleScreen.connect("signal", self, "forwardMessage")

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)