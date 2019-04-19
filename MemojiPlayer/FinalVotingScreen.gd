extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var answerChoicesToBeReturned = []

func _ready():
	# Called when the node is added to the scene for the first time.
	test_choices(5)
	get_node("SubmitButton").connect("pressed", self, "on_SubmitButton_Pressed")


func test_choices(x):
	for i in range(0, x):
		get_node("RankOne").add_item("ID " + str(i+1), i)
		get_node("RankTwo").add_item("ID " + str(i+1), i)
		get_node("RankThree").add_item("ID " + str(i+1), i)

func set_choices(answers):
	for i in range(0, answers.size()):
		get_node("RankOne").add_item("ID " + str(i), i)
		get_node("RankTwo").add_item("ID " + str(i), i)
		get_node("RankThree").add_item("ID " + str(i), i)
	#Done setting items in each option button
	

func on_SubmitButton_Pressed():
	#Message Change etc
	var rankOne = get_node("RankOne").get_selected_id()
	var rankTwo = get_node("RankTwo").get_selected_id()
	var rankThree = get_node("RankThree").get_selected_id()
	
	print(rankOne)
	print(rankTwo)
	print(rankThree)
	
	#get_node("PromptLabel").text = voteID
	#var msg = {
	#	"messageType": MESSAGE_TYPES.PLAYER_SENDING_SINGLE_VOTE,
	#	"voteID": voteID
	#}
	
	#emit_signal("send_message", msg)
	#reset_display()
	#emit_signal("change_screen", 4)
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
