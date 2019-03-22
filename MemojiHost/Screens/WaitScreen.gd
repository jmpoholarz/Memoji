extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

signal messageServer(msg)

var timer
var _TimerLabel

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	_TimerLabel = $MarginContainer/Timer
	timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.wait_time(60)
	add_child(timer)
	timer.start()
	pass

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	_TimerLabel.text = timer.time_left
	pass

# Add timer node on start
# Make label to display timer value

func _on_timer_timeout():
	print("TIMER OVER")
	var message = {"messageType": 320}
	emit_signal("messageServer", message)
