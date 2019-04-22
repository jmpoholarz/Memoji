extends Node

signal send_message(msg)
signal out_of_prompts()

onready var _EmojiCanvasEditor = $Panel/VBoxContainer/EmojiCanvasEditor
onready var _PromptLabel = $Panel/VBoxContainer/MarginContainer/HBoxContainer/PromptLabel
onready var _SubmitButton = $Panel/VBoxContainer/MarginContainer/HBoxContainer/SubmitButton
onready var _SubmitButtonTimer = $Timer

var prompt_array = []
var current_prompt = ""
var current_prompt_id = -1


func _ready():
	_SubmitButtonTimer.start()

func get_num_prompts():
	return prompt_array.size()

func add_prompts(prompt_array):
	for prompt in prompt_array:
		self.prompt_array.append(prompt)

func get_next_prompt():
	if prompt_array.size() <= 0:
		return
	# Get prompt text and remove from array of prompts
	current_prompt_id = prompt_array[0][0]
	current_prompt = prompt_array[0][1]
	prompt_array.pop_front()
	# Set label text
	_PromptLabel.text = current_prompt

func get_emoji_submission():
	return _EmojiCanvasEditor.get_emojis()

func _on_SubmitButton_pressed():
	# Disable button to prevent double press
	_SubmitButton.disabled = true
	_SubmitButtonTimer.start()
	# Send completed prompt to server
	var msg = {
			"messageType": MESSAGE_TYPES.PLAYER_SENDING_PROMPT_RESPONSE,
			"promptID": current_prompt_id,
			"emojiArray": get_emoji_submission()
		}
	emit_signal("send_message", msg)
	# Handle next prompt
	if prompt_array.size() > 0:
		get_next_prompt()
		_EmojiCanvasEditor.reset_canvas()
	else:
		emit_signal("out_of_prompts")


func _on_Timer_timeout():
	_SubmitButton.disabled = false
