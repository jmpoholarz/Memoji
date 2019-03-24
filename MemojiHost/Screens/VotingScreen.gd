extends Node2D

signal updateGameState(msg)

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_Timer_timeout():
	_TimerLabel.text = str(int(_TimerLabel.text)-1)
	if int(_TimerLabel) == 0:
		_Timer.stop()
		var message = {"messageType": MESSAGE_TYPES.HOST_TIME_UP}
		emit_signal("messageServer", message)
	pass # replace with function body
