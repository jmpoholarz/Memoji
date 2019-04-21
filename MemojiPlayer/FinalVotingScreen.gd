extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal connectToServer()
signal send_message(msg)
signal change_screen(screen)
var answerChoicesToBeReturned = []
onready var canvas1 = $Answer1/Emoji1
onready var canvas2 = $Answer2/Emoji2
onready var canvas3 = $Answer3/Emoji3
onready var canvas4 = $Answer4/Emoji4
onready var canvas5 = $Answer5/Emoji5
onready var canvas7 = $Answer6/Emoji6
onready var canvas6 = $Answer7/Emoji7
onready var canvas8 = $Answer8/Emoji8
onready var rankOneLabel = $Rank1Label
onready var rankTwoLabel = $Rank2Label
onready var rankThreeLabel = $Rank3Label
onready var choiceOneVector = Vector2(138, 165)
onready var choiceTwoVector = Vector2(423, 128)
onready var choiceThreeVector = Vector2(93, 498)
onready var choiceFourVector = Vector2(429, 491)
onready var choiceFiveVector = Vector2(66, 822)
onready var choiceSixVector = Vector2(93, 498)
onready var choiceSevenVector = Vector2(93, 498)
onready var choiceEightVector = Vector2(93, 498)

func _ready():
	# Called when the node is added to the scene for the first time.
	for i in range(3):
		answerChoicesToBeReturned.append(-1)
	#Test
	var test = []
	for i in range(4):
		test.append(-1)
		
	set_answers(test)
	
	
	get_node("SubmitButton").connect("pressed", self, "on_SubmitButton_Pressed")
	get_node("GridContainer/Answer1/B1").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer1/B1")])
	get_node("GridContainer/Answer2/B2").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer2/B2")])
	get_node("GridContainer/Answer3/B3").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer3/B3")])
	get_node("GridContainer/Answer4/B4").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer4/B4")])
	get_node("GridContainer/Answer5/B5").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer5/B5")])
	get_node("GridContainer/Answer6/B6").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer6/B6")])
	get_node("GridContainer/Answer7/B7").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer7/B7")])
	get_node("GridContainer/Answer8/B8").connect("toggled", self, "on_ButtonPressed", [get_node("GridContainer/Answer8/B8")])
	
	
func on_ButtonPressed(toggled, target):
	print("button = ", target.get_name())
	var id = -1
	
	if (target.get_name() == "B1"):
		id = 0
	elif (target.get_name() == "B2"):
		id = 1
	elif (target.get_name() == "B3"):
		id = 2
	elif (target.get_name() == "B4"):
		id = 3
	elif (target.get_name() == "B5"):
		id = 4
	elif (target.get_name() == "B6"):
		id = 5
	elif (target.get_name() == "B7"):
		id = 6
	elif (target.get_name() == "B8"):
		id = 7

	if toggled == true:
		var checkForFullArray = false
		
		for j in range(3):
			if(answerChoicesToBeReturned[j] == -1):
				checkForFullArray = true
		if !checkForFullArray:
			#set button to toggle back
			
			return
		for i in range(3):
			if checkForFullArray:
				if(answerChoicesToBeReturned[i] == -1):
					answerChoicesToBeReturned[i] = id
					print(answerChoicesToBeReturned)
					set_positionLabel(i, id)
					return		
	else:
		for i in range(3):
			if(answerChoicesToBeReturned[i] == id):
				remove_positionLabel(i)
				answerChoicesToBeReturned[i] = -1
		print(answerChoicesToBeReturned)
	print("Here")
	#set_positionLabel(answerChoicesToBeReturned)

func set_positionLabel(rank, id):
	if(rank == 0):
		if(id == 0):
			$Rank1Label.rect_position = choiceOneVector
		elif(id == 1):
			$Rank1Label.rect_position = choiceTwoVector
		elif(id == 2):
			$Rank1Label.rect_position = choiceThreeVector
		elif(id == 3):
			$Rank1Label.rect_position = choiceFourVector
		elif(id == 4):
			$Rank1Label.rect_position = choiceFiveVector
		elif(id == 5):
			$Rank1Label.rect_position = choiceSixVector
		elif(id == 6):
			$Rank1Label.rect_position = choiceSevenVector
		elif(id == 7):
			$Rank1Label.rect_position = choiceEightVector
		$Rank1Label.show()
	elif(rank == 1):
		if(id == 0):
			$Rank2Label.rect_position = choiceOneVector
		elif(id == 1):
			$Rank2Label.rect_position = choiceTwoVector
		elif(id == 2):
			$Rank2Label.rect_position = choiceThreeVector
		elif(id == 3):
			$Rank2Label.rect_position = choiceFourVector
		elif(id == 4):
			$Rank2Label.rect_position = choiceFiveVector
		elif(id == 5):
			$Rank2Label.rect_position = choiceSixVector
		elif(id == 6):
			$Rank2Label.rect_position = choiceSevenVector
		elif(id == 7):
			$Rank2Label.rect_position = choiceEightVector
		$Rank2Label.show()
	elif(rank == 2):
		if(id == 0):
			$Rank3Label.rect_position = choiceOneVector
		elif(id == 1):
			$Rank3Label.rect_position = choiceTwoVector
		elif(id == 2):
			$Rank3Label.rect_position = choiceThreeVector
		elif(id == 3):
			$Rank3Label.rect_position = choiceFourVector
		elif(id == 4):
			$Rank3Label.rect_position = choiceFiveVector
		elif(id == 5):
			$Rank3Label.rect_position = choiceSixVector
		elif(id == 6):
			$Rank3Label.rect_position = choiceSevenVector
		elif(id == 7):
			$Rank3Label.rect_position = choiceEightVector
		$Rank3Label.show()
			
	print("test")

func remove_positionLabel(i):
	if (i == 0):
		rankOneLabel.hide()
	elif (i == 1):
		rankTwoLabel.hide()
	elif(i == 2):
		rankThreeLabel.hide()
	print("test2")

func display_emojis(canvas,answer):
	canvas.decode_emojis(answer)
	return

#func reset_display():
#	canvas1.clear()
#	canvas2.clear()
	

func set_answers(answers):
	var answerNum = answers.size()
	get_node("GridContainer/Answer1").hide()
	get_node("GridContainer/Answer2").hide()
	get_node("GridContainer/Answer3").hide()
	get_node("GridContainer/Answer4").hide()
	get_node("GridContainer/Answer5").hide()
	get_node("GridContainer/Answer6").hide()
	get_node("GridContainer/Answer7").hide()
	get_node("GridContainer/Answer8").hide()
	
	if(answerNum == 2):
		get_node("GridContainer/Answer1").show()
		get_node("GridContainer/Answer2").show()
		display_emojis(canvas1,answers[0])
		display_emojis(canvas2,answers[1])
		
	elif(answerNum > 2 && answerNum <= 8):
		for i in range(0, answerNum):
			print(i)
			if(i == 0):
				get_node("GridContainer/Answer1").show()
				display_emojis(canvas1,answers[0])
			elif(i == 1):
				get_node("GridContainer/Answer2").show()
				display_emojis(canvas2,answers[1])				
			elif(i == 2):
				get_node("GridContainer/Answer3").show()
				display_emojis(canvas3,answers[2])
			elif(i == 3):
				get_node("GridContainer/Answer4").show()		
				display_emojis(canvas4,answers[3])
			elif(i == 4):
				get_node("GridContainer/Answer5").show()
				display_emojis(canvas5,answers[4])
			elif(i == 5):
				get_node("GridContainer/Answer6").show()
				display_emojis(canvas6,answers[5])
			elif(i == 6):
				get_node("GridContainer/Answer7").show()
				display_emojis(canvas7,answers[6])
			elif(i == 7):
				get_node("GridContainer/Answer8").show()
				display_emojis(canvas8,answers[7])
			
	else:
		print("Error: AnswerNumber value is less than 2")

func on_SubmitButton_Pressed():
	#Message Change etc
	var check = true
	for i in range(3):
		if(answerChoicesToBeReturned[i] == -1):
			check = false
	
	if check:
		var voteArray = answerChoicesToBeReturned
		var msg = {
			"messageType": MESSAGE_TYPES.PLAYER_SENDING_MULTI_VOTE,
			"voteArray": voteArray
		}
		emit_signal("send_message", msg)
		reset_display()
		emit_signal("change_screen", 4)
		print("Submitted")
	else:
		print("Cant be submitted")
	
