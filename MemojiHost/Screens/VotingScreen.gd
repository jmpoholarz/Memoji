extends Node2D

onready var _TimerLabel = $Foreground/TimerLabel
onready var _Timer = $Timer
onready var canvas1 = $Foreground/Answer1/Emojis1
onready var canvas2 = $Foreground/Answer2/Emojis2

var remainingTime = 60
signal updateGameState(msg)

func display_emojis(answer1, answer2):
	canvas1.decode_emojis(answer1)
	canvas2.decode_emojis(answer2)
	return

func reset_display():
	canvas1.clear()
	canvas2.clear()

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	_Timer.start()
	pass

func _on_Timer_timeout():
	remainingTime -= 1
	
	if int(remainingTime) == 0:
		_Timer.stop()
		var message = {"messageType": MESSAGE_TYPES.HOST_TIME_UP}
		emit_signal("messageServer", message)
		
	_TimerLabel.text = str(remainingTime)
	pass # replace with function body
