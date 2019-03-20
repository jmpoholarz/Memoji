extends Node

signal send_message(msg)
signal out_of_prompts()

var _EmojiCanvasEditor
var _PromptLabel

var prompt_array = []
var current_prompt = ""


func _ready():
	_EmojiCanvasEditor = $Panel/VBoxContainer/EmojiCanvasEditor
	_PromptLabel = $Panel/VBoxContainer/MarginContainer/HBoxContainer/PromptLabel
	
	#prompt_array.push_back("First prompt.")
	#prompt_array.push_back("Second prompt.")
	#prompt_array.push_back("Third prompt.")
	#prompt_array.push_back("This is a very long prompt which would be expected to take up more than one line of the editor " + \
	#	"in which case all of the words should push the rest of the content in this screen downward, reducing the size of " + \
	#	"the emoji palette.")

func set_prompts(prompt_array):
	for prompt in prompt_array:
		self.prompt_array.append(prompt)

func get_next_prompt():
	if prompt_array.size() <= 0:
		return
	# Get prompt text and remove from array of prompts
	current_prompt = prompt_array[0]
	prompt_array.pop_front()
	# Set label text
	_PromptLabel.text = current_prompt

func get_emoji_submission():
	return _EmojiCanvasEditor.get_emojis()

func _on_SubmitButton_pressed():
	# Send completed prompt to server
	var msg = {
			"messageType": MESSAGE_TYPES.PLAYER_SENDING_PROMPT_RESPONSE,
			"emojiArray": get_emoji_submission()
		}
	emit_signal("send_message", msg)
	# Handle next prompt
	if prompt_array.size() > 0:
		get_next_prompt()
		_EmojiCanvasEditor.reset_canvas()
	else:
		emit_signal("out_of_prompts")
