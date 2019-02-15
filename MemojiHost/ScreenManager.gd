extends Node

signal sendMessageToServer(msg)

enum SCREENS {
	TITLE_SCREEN = 1
}

var currentScene

func _ready():
	pass

# TODO: Free the previous screeen when switching to a different one
func changeScreenTo(screen):
	match screen:
		TITLE_SCREEN:
			var titleScreen = load("res://TitleScreen.tscn")
			add_child(titleScreen.instance())
			#titleScreen.connect("signal", self, "forwardMessage")

func forwardMessage(msg):
	emit_signal("sendMessageToServer", msg)