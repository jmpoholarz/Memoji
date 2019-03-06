extends Node

var prompt_scene = preload("res://Prompt.tscn")

const TOTAL_QUESTIONS = 21

var active_prompt_ids = []
var active_prompts = {}

func _ready():
	__unit_test_get_new_prompt()
	pass

func setAnswer(prompt_id, player_id, answer):
	active_prompts[prompt_id].add_player_answer(player_id, answer)

func set_vote(prompt_id, player_id, answer_index):
	active_prompts[prompt_id].add_player_vote(player_id, answer_index)

func get_answers_to_prompt(prompt_id):
	var answers = []
	for answer in active_prompts[prompt_id].get_answers():
		answers += answer.emojis



func create_prompt():
	# Get data stored in prompt
	var prompt_data = _get_new_prompt()
	var prompt_id = prompt_data[0]
	var prompt_text = prompt_data[1]
	# Create prompt object and add as child
	var prompt_obj = prompt_scene.instance()
	prompt_obj.set_prompt_id(prompt_id)
	prompt_obj.set_prompt_text(prompt_text)
	add_child(prompt_obj)
	# Return the prompt object if needed
	return prompt_obj

func _get_new_prompt(prompt_number = -1):
	if active_prompt_ids.size() == TOTAL_QUESTIONS:
		print("Failed to generate new prompt as all prompts have been chosen.  Resetting.")
		active_prompt_ids.clear()
	# Generate random number
	while prompt_number < 0 || prompt_number >= TOTAL_QUESTIONS || prompt_number in active_prompt_ids:
		prompt_number = randi() % TOTAL_QUESTIONS
	# Read in prompt from that line of the file
	var prompt_text = ""
	var f = File.new()
	var status = f.open("res://Assets/text/en_us/prompts_0.tres", File.READ)
	if status != OK:
		print("Failed to open prompt file prompts_0.tres.  Setting prompt string to ERROR.")
		Logger.writeLine("Failed to open prompt file prompts_0.tres.  Setting prompt string to ERROR.")
		prompt_text = "ERROR.  See log file for details."
		return prompt_text
	for i in range(prompt_number):
		f.get_line()
	prompt_text = f.get_line()
	f.close()
	print(str(prompt_number) + ":::" + prompt_text)
	# Add chosen prompts to activePrompts so it isn't chosen again
	active_prompt_ids.append(prompt_number)
	return prompt_text








func __unit_test_get_new_prompt():
	_get_new_prompt(0)
	_get_new_prompt(1)
	_get_new_prompt(14)
	_get_new_prompt(20)
	_get_new_prompt(21)
	_get_new_prompt(22)
	_get_new_prompt(-2)
	_get_new_prompt(1)
	_get_new_prompt(14)
	
	var prompt_obj = create_prompt()
	prompt_obj.add_player_answer(333, "abcd")
	print(str(prompt_obj.get_players()[0]))
	
	## TODO test more getters