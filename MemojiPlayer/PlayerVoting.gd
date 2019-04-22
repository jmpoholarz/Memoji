extends Panel

signal send_message(msg)
signal change_screen(screen)

onready var _Canvases = [$VBoxContainer/HBoxContainer/Canvas0,
						 $VBoxContainer/HBoxContainer/Canvas1]

onready var _PromptLabel = $VBoxContainer/PromptLabel
onready var _SubmitButton = $VBoxContainer/SubmitButton
onready var _StarTexture = $StarTexture

var vote_id = -1

func _ready():
	pass

func set_answers(answers, prompt_text):
	if answers.size() != 2:
		print("Error: number of answers not equal to 2")
		return
	_PromptLabel.text = prompt_text
	_Canvases[0].decode_emojis(answers[0])
	_Canvases[1].decode_emojis(answers[1])

func _on_ChoiceButton_pressed(button_index):
	vote_id = button_index
	_SubmitButton.disabled = false
	_StarTexture.rect_position = _Canvases[button_index].rect_global_position
	_StarTexture.visible = true

func _on_SubmitButton_pressed():
	_SubmitButton.disabled = true
	var msg = {
		"messageType": MESSAGE_TYPES.PLAYER_SENDING_SINGLE_VOTE,
		"voteID": vote_id
	}
	emit_signal("send_message", msg)
	emit_signal("change_screen", 4)

