extends Panel

signal connectToServer()
signal send_message(msg)
signal change_screen(screen)
var answerChoicesToBeReturned = []
onready var _Canvases = [$GridContainer/Answer1/Emoji1,
						 $GridContainer/Answer2/Emoji2,
						 $GridContainer/Answer3/Emoji3, 
						 $GridContainer/Answer4/Emoji4,
						 $GridContainer/Answer5/Emoji5,
						 $GridContainer/Answer6/Emoji6,
						 $GridContainer/Answer7/Emoji7,
						 $GridContainer/Answer8/Emoji8]
onready var _SubmitButton = $SubmitButton
onready var rankOneLabel = $Rank1Label
onready var rankTwoLabel = $Rank2Label
onready var rankThreeLabel = $Rank3Label

func _ready():
	# Called when the node is added to the scene for the first time.
	for i in range(3):
		answerChoicesToBeReturned.append(-1)
	#Test
	var test = []
	for i in range(8):
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
			$Rank1Label.rect_position = _Canvases[0].rect_global_position
		elif(id == 1):
			$Rank1Label.rect_position = _Canvases[1].rect_global_position
		elif(id == 2):
			$Rank1Label.rect_position = _Canvases[2].rect_global_position
		elif(id == 3):
			$Rank1Label.rect_position = _Canvases[3].rect_global_position
		elif(id == 4):
			$Rank1Label.rect_position = _Canvases[4].rect_global_position
		elif(id == 5):
			$Rank1Label.rect_position = _Canvases[5].rect_global_position
		elif(id == 6):
			$Rank1Label.rect_position = _Canvases[6].rect_global_position
		elif(id == 7):
			$Rank1Label.rect_position = _Canvases[7].rect_global_position
		$Rank1Label.show()
	elif(rank == 1):
		if(id == 0):
			$Rank2Label.rect_position = _Canvases[0].rect_global_position
		elif(id == 1):
			$Rank2Label.rect_position = _Canvases[1].rect_global_position
		elif(id == 2):
			$Rank2Label.rect_position = _Canvases[2].rect_global_position
		elif(id == 3):
			$Rank2Label.rect_position = _Canvases[3].rect_global_position
		elif(id == 4):
			$Rank2Label.rect_position = _Canvases[4].rect_global_position
		elif(id == 5):
			$Rank2Label.rect_position = _Canvases[5].rect_global_position
		elif(id == 6):
			$Rank2Label.rect_position = _Canvases[6].rect_global_position
		elif(id == 7):
			$Rank2Label.rect_position = _Canvases[7].rect_global_position
		$Rank2Label.show()
	elif(rank == 2):
		if(id == 0):
			$Rank3Label.rect_position = _Canvases[0].rect_global_position
		elif(id == 1):
			$Rank3Label.rect_position = _Canvases[1].rect_global_position
		elif(id == 2):
			$Rank3Label.rect_position = _Canvases[2].rect_global_position
		elif(id == 3):
			$Rank3Label.rect_position = _Canvases[3].rect_global_position
		elif(id == 4):
			$Rank3Label.rect_position = _Canvases[4].rect_global_position
		elif(id == 5):
			$Rank3Label.rect_position = _Canvases[5].rect_global_position
		elif(id == 6):
			$Rank3Label.rect_position = _Canvases[6].rect_global_position
		elif(id == 7):
			$Rank3Label.rect_position = _Canvases[7].rect_global_position
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
	var test = [[0,0,10080], [0,2,10080], [2,0,10080]]
	canvas.decode_emojis(test)
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
		display_emojis(_Canvases[0],answers[0])
		display_emojis(_Canvases[1],answers[1])
		
	elif(answerNum > 2 && answerNum <= 8):
		for i in range(0, answerNum):
			print(i)
			if(i == 0):
				get_node("GridContainer/Answer1").show()
				display_emojis(_Canvases[0],answers[0])
			elif(i == 1):
				get_node("GridContainer/Answer2").show()
				display_emojis(_Canvases[1],answers[1])				
			elif(i == 2):
				get_node("GridContainer/Answer3").show()
				display_emojis(_Canvases[2],answers[2])
			elif(i == 3):
				get_node("GridContainer/Answer4").show()		
				display_emojis(_Canvases[3],answers[3])
			elif(i == 4):
				get_node("GridContainer/Answer5").show()
				display_emojis(_Canvases[4],answers[4])
			elif(i == 5):
				get_node("GridContainer/Answer6").show()
				display_emojis(_Canvases[5],answers[5])
			elif(i == 6):
				get_node("GridContainer/Answer7").show()
				display_emojis(_Canvases[6],answers[6])
			elif(i == 7):
				get_node("GridContainer/Answer8").show()
				display_emojis(_Canvases[7],answers[7])
			
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
		emit_signal("change_screen", 4)
		print("Submitted")
		print(answerChoicesToBeReturned)
	else:
		print("Cant be submitted")
	
