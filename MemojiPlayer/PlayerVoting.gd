extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal connectToServer()
signal send_message(msg)
signal changeVotingOption(ChoiceId)
signal voting_has_ended()
signal change_screen(screen)

var buttonID


var answerNum = 0

func _ready():
	get_node("GridContainer/ChoiceOneButton").connect("pressed", self, "on_ChoiceOne_Pressed")
	get_node("GridContainer/ChoiceTwoButton").connect("pressed", self, "on_ChoiceTwo_Pressed")
	get_node("GridContainer/ChoiceThreeButton").connect("pressed", self, "on_ChoiceThree_Pressed")
	get_node("GridContainer/ChoiceFourButton").connect("pressed", self, "on_ChoiceFour_Pressed")
	get_node("GridContainer/ChoiceFiveButton").connect("pressed", self, "on_ChoiceFive_Pressed")
	get_node("GridContainer/ChoiceSixButton").connect("pressed", self, "on_ChoiceSix_Pressed")
	get_node("GridContainer/ChoiceSevenButton").connect("pressed", self, "on_ChoiceSeven_Pressed")
	get_node("GridContainer/ChoiceEightButton").connect("pressed", self, "on_ChoiceEight_Pressed")
	
	#set_answers([0,1,2,3,4,5,6])
	
	get_node("SubmitButton").connect("pressed", self, "on_SubmitButton_Pressed")
	#Get Single prompt 
	#Get Choice option ID's 0 or 1
	#Display the Prompt in the label PromptLabel
	#When clicked on an answer send the answer ID to the server to send to host
	#Redirect the player to the waiting screen
	#Send Answer for Voting func in gsm
	
func set_answers(answers):
	answerNum = answers.size()
	#hididng all buttons in grid
	
	get_node("GridContainer/ChoiceOneButton").hide()
	get_node("GridContainer/ChoiceTwoButton").hide()
	get_node("GridContainer/ChoiceThreeButton").hide()
	get_node("GridContainer/ChoiceFourButton").hide()
	get_node("GridContainer/ChoiceFiveButton").hide()
	get_node("GridContainer/ChoiceSixButton").hide()
	get_node("GridContainer/ChoiceSevenButton").hide()
	get_node("GridContainer/ChoiceEightButton").hide()
	
	if(answerNum == 2):
		get_node("GridContainer/ChoiceOneButton").show()
		get_node("GridContainer/ChoiceTwoButton").show()
	elif(answerNum > 2 && answerNum <= 8):
		for i in range(0, answerNum):
			print(i)
			if(i == 0):
				get_node("GridContainer/ChoiceOneButton").show()
			elif(i == 1):
				get_node("GridContainer/ChoiceTwoButton").show()				
			elif(i == 2):
				get_node("GridContainer/ChoiceThreeButton").show()
			elif(i == 3):
				get_node("GridContainer/ChoiceFourButton").show()		
			elif(i == 4):
				get_node("GridContainer/ChoiceFiveButton").show()
			elif(i == 5):
				get_node("GridContainer/ChoiceSixButton").show()
			elif(i == 6):
				get_node("GridContainer/ChoiceSevenButton").show()
			elif(i == 7):
				get_node("GridContainer/ChoiceEightutton").show()
			
	else:
		print("Error: AnswerNumber value is less than 2")

func set_answer_label():
	var answer1 = "Choice One"
	var answer2 = "Choice Two"
	get_node("GridContainer/ChoiceOneButton").text = answer1
	get_node("GridContainer/ChoiceTwoButton").text = answer2

func on_ChoiceOne_Pressed():
	buttonID = "0"

func on_ChoiceTwo_Pressed():
	buttonID = "1"

func on_ChoiceThree_Pressed():
	buttonID = "2"

func on_ChoiceFour_Pressed():
	buttonID = "3"

func on_ChoiceFive_Pressed():
	buttonID = "4"

func on_ChoiceSix_Pressed():
	buttonID = "5"
	
func on_ChoiceSeven_Pressed():
	buttonID = "6"
	
func on_ChoiceEight_Pressed():
	buttonID = "7"

func on_SubmitButton_Pressed():
	var voteID = buttonID
	get_node("PromptLabel").text = voteID
	var msg = {
		"messageType": MESSAGE_TYPES.PLAYER_SENDING_SINGLE_VOTE,
		"voteID": voteID
	}
	
	emit_signal("send_message", msg)
	emit_signal("change_screen", 4)
	

func receive_Prompt(prompt):
	get_node("PromptLabel").text = prompt

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
