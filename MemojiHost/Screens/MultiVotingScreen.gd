extends Panel

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

var _CanvasScene = preload("res://Screens/Elements/EmojiCanvas.tscn")

onready var _PromptLabel = $VBoxContainer/PromptLabel
onready var _GridContainer = $VBoxContainer/CenterContainer/GridContainer
onready var _TimerLabel = $VBoxContainer/TimerLabel
onready var _Timer = $Timer

var number_of_answers_loaded = 0
var answer_displays = []

func update_prompt_label(prompt_text):
	_PromptLabel.text = prompt_text

func load_answer(emojis):
	# Error check
	if number_of_answers_loaded >= 8:
		return
	var canvas_instance = _CanvasScene.instance()
	# Add to grid and reference array
	canvas_instance.resize_factor = 0.5
	_GridContainer.add_child(canvas_instance)
	answer_displays.append(canvas_instance)
	number_of_answers_loaded += 1
	canvas_instance.decode_emojis(emojis)

func _on_Timer_timeout():
	var time_left = int(_TimerLabel.text)
	time_left -= 1
	_TimerLabel.text = str(time_left)
	if time_left == 0:
		$Timer.stop()
		#TODO transition to next screen

func _ready():
	#load_answer([[2,2,10080]])
	#load_answer([[3,3,10090]])
	#load_answer([[1,1,10010]])
	#load_answer([[2,2,10080]])
	#load_answer([[3,3,10090]])
	#load_answer([[1,1,10010]])
	pass

