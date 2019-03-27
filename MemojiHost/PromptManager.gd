extends Node

const TOTAL_QUESTIONS = 21

var active_prompt_ids = []
var active_prompts = {}

func _ready():
	#__unit_test_get_new_prompt()
	pass
	
func reset():
	active_prompts.clear()
	active_prompt_ids.clear()

func set_answer(prompt_id, player_id, answer):
	if (active_prompts.has(prompt_id)):
		active_prompts[prompt_id].add_player_answer(player_id, answer)
		return true
	else:
		return false

func set_vote(prompt_id, player_id, answer_index):
	if (active_prompts.has(prompt_id)):
		active_prompts[prompt_id].add_player_vote(player_id, answer_index)
		return true
	else:
		return false

# NEW - now returns the entire answer object instead of only EmojiArray
# See Prompt.gd for more info
func get_answers_to_prompt(prompt_id):
	var answers = []
	for answer in active_prompts[prompt_id].get_answers():
		answers.append(answer)
	return answers

func check_completion(): # Checks that each prompt has been answered
	for prompt in active_prompts:
		if (prompt.player_answers.size() < 2):
			return false
	
	return true

func create_prompt():
	# Get data stored in prompt
	var prompt_data = _get_new_prompt().split("%%%")
	var prompt_id = int(prompt_data[0])
	var prompt_text = prompt_data[1]

	# Create prompt object and add to active prompt dictionary
	var prompt_obj = GlobalVars.PromptClass.new()
	prompt_obj.set_prompt_id(prompt_id)
	prompt_obj.set_prompt_text(prompt_text)
	active_prompts[prompt_obj.get_prompt_id()] = prompt_obj
	
	# Return the prompt object if needed
	return prompt_obj

func _get_new_prompt(prompt_number = -1):
	if active_prompt_ids.size() == TOTAL_QUESTIONS:
		print("Failed to generate new prompt as all prompts have been chosen.  Resetting.")
		reset()
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
#	print(str(prompt_obj.get_players()[0]))
	print(prompt_obj.get_prompt_id())
	print(prompt_obj.get_prompt_text())
	print(prompt_obj.get_answer_from_player(333))
	print("\n")
	
	for x in active_prompts.keys():
		print("Key: ", x, ", Prompt ID: ", active_prompts[x].get_prompt_id())
		pass
	
	## TODO test more getters