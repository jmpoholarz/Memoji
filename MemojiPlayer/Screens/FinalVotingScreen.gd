extends Panel

signal send_message(msg)
signal change_screen(screen)

onready var _Answers = [$VBoxContainer/ScrollContainer/GridContainer/Answer0, $VBoxContainer/ScrollContainer/GridContainer/Answer1,
						$VBoxContainer/ScrollContainer/GridContainer/Answer2, $VBoxContainer/ScrollContainer/GridContainer/Answer3,
						$VBoxContainer/ScrollContainer/GridContainer/Answer4, $VBoxContainer/ScrollContainer/GridContainer/Answer5,
						$VBoxContainer/ScrollContainer/GridContainer/Answer6, $VBoxContainer/ScrollContainer/GridContainer/Answer7]
onready var _Canvases = [$VBoxContainer/ScrollContainer/GridContainer/Answer0/Canvas0, 
						$VBoxContainer/ScrollContainer/GridContainer/Answer1/Canvas1,
						$VBoxContainer/ScrollContainer/GridContainer/Answer2/Canvas2,
						$VBoxContainer/ScrollContainer/GridContainer/Answer3/Canvas3,
						$VBoxContainer/ScrollContainer/GridContainer/Answer4/Canvas4,
						$VBoxContainer/ScrollContainer/GridContainer/Answer5/Canvas5,
						$VBoxContainer/ScrollContainer/GridContainer/Answer6/Canvas6,
						$VBoxContainer/ScrollContainer/GridContainer/Answer7/Canvas7]
onready var _VoteIcons = [$GoldIcon, $SilverIcon, $BronzeIcon]

var votes_chosen = [-1, -1, -1]

#func _ready():
	#set_answers([ [[0,0,10090]], [[0,0,10090]], [[0,0,10090]], [[0,0,10090]], [[0,0,10090]] ])

func set_answers(answers):
	if answers.size() < 2:
		print("Error: AnswerNumber value is less than 2")
		return
	elif answers.size() <= 8:
		for i in range(answers.size()):
			_Canvases[i].decode_emojis(answers[i])
			_Answers[i].visible = true

func _on_Button_pressed(button_id):
	# Check if answer had already been selected
	for i in range(3):
		if votes_chosen[i] == button_id:
			# Untoggle chosen answer
			votes_chosen[i] = -1
			hide_vote_icon(i)
			return
	# Handle answer not yet selected
	for i in range(3):
		if votes_chosen[i] == -1:
			# Found an un-chosen vote rank
			votes_chosen[i] = button_id
			show_vote_icon(i, button_id)
			return

func show_vote_icon(vote_rank, button_id):
	_VoteIcons[vote_rank].rect_position = _Canvases[button_id].rect_global_position
	_VoteIcons[vote_rank].visible = true

func hide_vote_icon(vote_rank):
	_VoteIcons[vote_rank].visible = false

func _on_SubmitButton_pressed():
	# Handle didn't set all votes
	for i in range(3):
		if(votes_chosen[i] == -1):
			print("Can't be submitted")
			return
	# Send valid votes
	var msg = {
		"messageType": MESSAGE_TYPES.PLAYER_SENDING_MULTI_VOTE,
		"voteArray": votes_chosen
	}
	emit_signal("send_message", msg)
	emit_signal("change_screen", 4)
	print("Submitted")
	print(votes_chosen)
