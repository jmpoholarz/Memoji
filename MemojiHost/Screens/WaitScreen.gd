extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal messageServer(msg)

var _TimerLabel
var _Timer

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	_TimerLabel = $MarginContainer/TimerLabel
	_Timer = $Timer
	pass

#func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
#	pass

# Add timer node on start
# Make label to display timer value

func _on_Timer_timeout():
	_TimerLabel.text = str(int(_TimerLabel.text)-1)
	if int(_TimerLabel) == 0:
		_Timer.stop()
		var message = {"messageType": 320}
		emit_signal("messageServer", message)
	pass # replace with function body
