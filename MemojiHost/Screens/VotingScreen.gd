extends Panel
signal updateGameState(msg)
signal changeScreen()
signal messageServer()

onready var _TimerLabel = $TimerLabel
onready var _Timer = $Timer
onready var canvas1 = $VBoxContainer/HBoxContainer/Answer1/Emojis1
onready var canvas2 = $VBoxContainer/HBoxContainer/Answer2/Emojis2
onready var promptLabel = $VBoxContainer/PromptLabel

var remainingTime = 10

func display_emojis(answer1, answer2):
	canvas1.decode_emojis(answer1)
	canvas2.decode_emojis(answer2)
	return
	
func display_prompt_text(text):
	promptLabel.text = text
	promptLabel.show()

func reset_display():
	canvas1.clear()
	canvas2.clear()
	promptLabel.hide()

func _ready():
	_Timer.start()

func _on_Timer_timeout():
	_TimerLabel.text = str(int(_TimerLabel.text)-1)
	if int(_TimerLabel.text) == 0:
		_Timer.stop()
		var message = {"messageType": 320}
		emit_signal("messageServer", message)
		emit_signal("changeScreen", GlobalVars.RESULTS_SCREEN)
