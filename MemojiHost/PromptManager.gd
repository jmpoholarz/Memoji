extends Node

const TOTAL_QUESTIONS = 107

var active_prompt_ids = []
var active_prompts = {}

func _ready():
	#__unit_test_get_new_prompt()
	pass
	
func reset():
	active_prompts.clear()
	active_prompt_ids.clear()

func set_answer(prompt_id, player_id, answer):
	print("DEBUG: prompt answer - ", prompt_id)
	print("Dictionary: ", active_prompts)
	if (active_prompts.has(prompt_id)):
		active_prompts[prompt_id].update_player_answer(player_id, answer)
		print("DEBUG: prompt answer added successfully")
		return true
	else:
		return false

func set_vote(prompt_id, player_id, answer_index):
	if (active_prompts.has(prompt_id)):
		active_prompts[prompt_id].add_player_vote(player_id, answer_index)
		return true
	else:
		return false

func get_prompt_by_id(prompt_id):
	if (active_prompts.has(prompt_id)):
		return active_prompts[prompt_id]
	else:
		return null

func get_answers_to_prompt(prompt_id): # Returns array of EmojiArrays
	var answers = []
	var answerObjArr = active_prompts[prompt_id].get_answers()
	for index in range(answerObjArr.size()):
		answers.append(answerObjArr[index].emojis)
	
	return answers
	
func get_votes(prompt_id, vote_index):
	var promptObj = active_prompts[prompt_id]
	
	return promptObj.get_number_of_votes_for_answer(vote_index)

func get_supporters(prompt_id, vote_index):
	var promptObj = active_prompts[prompt_id]
	return promptObj.get_voters_for_answer(vote_index)

func check_completion(): # Checks that each prompt has been answered
	var promptObj
	
	for k in active_prompts.keys():
		promptObj = active_prompts[k]
		print("DEBUG: Prompt - ", promptObj.get_prompt_text())
		print("* answer count: ", promptObj.player_answers.size())
		
		if (promptObj.answers_completed < promptObj.player_answers.size()):
			return false
	
	return true

# OLD FUNCTION
#func check_votes(promptID, numPlayers): # Checks every player voted on the prompt
#	var promptObj = active_prompts[promptID]
#	if (promptObj.get_votes().size() < numPlayers):
#		return false
		
#	return true
# TODO: handle audience
# players is an Array of Player objects
# finalFlag is true if on final round (triple voting)
func check_votes(players, audiencePlayers, finalFlag = false):
	for p in players:
		if (!(p.check_vote(finalFlag))):
			return false
	# Check that audience is also done voting
	for p in audiencePlayers:
		if (!(p.check_vote(finalFlag))):
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
	active_prompt_ids.append(prompt_obj.get_prompt_id())
	
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
	#active_prompt_ids.append(prompt_number)
	return prompt_text








func __unit_test_get_new_prompt():
	#_get_new_prompt(0)
	#_get_new_prompt(1)
	#_get_new_prompt(14)
	#_get_new_prompt(20)
	#_get_new_prompt(21)
	#_get_new_prompt(22)
	#_get_new_prompt(-2)
	#_get_new_prompt(1)
	#_get_new_prompt(14)
	
	var prompt_obj = create_prompt()
	prompt_obj.add_player_answer(333, "abcd")
#	print(str(prompt_obj.get_players()[0]))
	print(prompt_obj.get_prompt_id())
	print(prompt_obj.get_prompt_text())
	print(prompt_obj.get_answer_from_player(333))
	print("\n")
	
	create_prompt()
	create_prompt()
	
	
	for x in active_prompts.keys():
		print("Key: ", x, ", Prompt ID: ", active_prompts[x].get_prompt_id())
		set_answer(x, 123, "abcd")
		set_answer(x, 22, "jkl")
		check_completion()
		pass
	