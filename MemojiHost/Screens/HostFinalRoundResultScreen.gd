extends Panel

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

var _FinalRoundDisplayScene = preload("res://Screens/Elements/FinalRoundDisplay.tscn")

onready var _PromptLabel = $VBoxContainer/PromptLabel
onready var _GridContainer = $VBoxContainer/GridContainer

var number_of_answers_loaded = 0
var answer_displays = []

func update_prompt_label(prompt_text):
	_PromptLabel.text = prompt_text

func load_answer(username, emojis, gold_count, silver_count, bronze_count):
	# Error check
	if number_of_answers_loaded >= 8:
		return
	var final_round_display_instance = _FinalRoundDisplayScene.instance()
	# Add to grid and reference array
	_GridContainer.add_child(final_round_display_instance)
	answer_displays.append(final_round_display_instance)
	number_of_answers_loaded += 1
	# Setup display with given information
	final_round_display_instance.set_player_name(username)
	final_round_display_instance.decode_emojis(emojis)
	final_round_display_instance.set_golds(gold_count)
	final_round_display_instance.set_silvers(silver_count)
	final_round_display_instance.set_bronzes(bronze_count)
	#TODO Score calulation
	var final_round_score = gold_count * 100 + silver_count * 50 + bronze_count * 25
	final_round_display_instance.set_points(final_round_score)

func _ready():
	#load_answer("Applesauce", [[2,2,10080]], 3, 0, 1)
	#load_answer("Tomato soup", [[3,3,10090]], 2, 3, 0)
	#load_answer("Orange juice", [[1,1,10010]], 0, 2, 4)
	pass

func _on_NextButton_pressed():
	pass # replace with function body
