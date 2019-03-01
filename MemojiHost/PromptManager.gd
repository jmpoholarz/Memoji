extends Node

const TOTAL_QUESTIONS = 4

var active_prompts = []

func _ready():
	__unit_test_get_new_prompt()
	pass

func setAnswer(playerID, promptID):
	pass

func _get_new_prompt(prompt_number = -1):
	if active_prompts.size() == TOTAL_QUESTIONS:
		print("Failed to generate new prompt as all prompts have been chosen.  Resetting.")
		active_prompts.clear()
	# Generate random number
	while prompt_number < 0 || prompt_number >= TOTAL_QUESTIONS || prompt_number in active_prompts:
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
	active_prompts.append(prompt_number)
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