extends Panel

signal messageServer(msg)

onready var _TimerLabel = $TimerContainer/TimerLabel
onready var _Timer = $Timer 
onready var confirmDisplay = $ConfirmationRow



# Add timer node on start
# Make label to display timer value

func _on_Timer_timeout():
	_TimerLabel.text = str(int(_TimerLabel.text)-1)
	if int(_TimerLabel.text) == 0:
		_Timer.stop()
		var message = {"messageType": 320}
		emit_signal("messageServer", message)
	pass # replace with function body
