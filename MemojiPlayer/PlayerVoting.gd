extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal connectToServer()
signal send_message(msg)
signal changeVotingOption(ChoiceId)
signal voting_has_ended()
signal change_screen(screen)
onready var canvas1 = $Answer1/Emoji1
onready var canvas2 = $Answer2/Emoji2

var buttonID


var answerNum = 0

func _ready():
	get_node("GridContainer/ChoiceOneButton").connect("pressed", self, "on_ChoiceOne_Pressed")
	get_node("GridContainer/ChoiceTwoButton").connect("pressed", self, "on_ChoiceTwo_Pressed")
	
	get_node("SubmitButton").connect("pressed", self, "on_SubmitButton_Pressed")
	#Get Single prompt 
	#Get Choice option ID's 0 or 1
	#Display the Prompt in the label PromptLabel
	#When clicked on an answer send the answer ID to the server to send to host
	#Redirect the player to the waiting screen
	#Send Answer for Voting func in gsm

func display_emojis(answer1, answer2):
	canvas1.decode_emojis(answer1)
	canvas2.decode_emojis(answer2)
	return

func reset_display():
	canvas1.clear()
	canvas2.clear()
	
func set_answers(answers):
	answerNum = answers.size()
	
	display_emojis(answers[0],answers[1])
	#hididng all buttons in grid
	
	get_node("GridContainer/ChoiceOneButton").hide()
	get_node("GridContainer/ChoiceTwoButton").hide()
	
	if(answerNum == 2):
		get_node("GridContainer/ChoiceOneButton").show()
		get_node("GridContainer/ChoiceTwoButton").show()
	else:
		print("Error: AnswerNumber value is less than 2")

func set_answer_label():
	var answer1 = "Choice One"
	var answer2 = "Choice Two"
	get_node("GridContainer/ChoiceOneButton").text = answer1
	get_node("GridContainer/ChoiceTwoButton").text = answer2

func on_ChoiceOne_Pressed():
	buttonID = "0"


func on_SubmitButton_Pressed():
	var voteID = buttonID
	get_node("PromptLabel").text = voteID
	var msg = {
		"messageType": MESSAGE_TYPES.PLAYER_SENDING_SINGLE_VOTE,
		"voteID": voteID
	}
	
	emit_signal("send_message", msg)
	reset_display()
	emit_signal("change_screen", 4)
	

func receive_Prompt(prompt):
	get_node("PromptLabel").text = prompt

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
