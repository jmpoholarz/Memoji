extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal connectToServer()
signal sendMessage(msg)
signal changeVotingOption(ChoiceId)
var buttonID

func _ready():
	get_node("ChoiceOneButton").connect("pressed", self, "on_ChoiceOne_Pressed")
	get_node("ChoiceTwoButton").connect("pressed", self, "on_ChoiceTwo_Pressed")
	get_node("SubmitButton").connect("pressed", self, "on_SubmitButton_Pressed")
	#Get Single prompt 
	#Get Choice option ID's 0 or 1
	#Display the Prompt in the label PromptLabel
	#When clicked on an answer send the answer ID to the server to send to host
	#Redirect the player to the waiting screen
	#Send Answer for Voting func in gsm
	
func on_ChoiceOne_Pressed():
	buttonID = "0"

func on_ChoiceTwo_Pressed():
	buttonID = "1"

func on_SubmitButton_Pressed():
	var name = buttonID
	get_node("PromptLabel").text = name

func receive_PromptArray(promptArray):
	var prompt = promptArray[0] 
	get_node("PromptLabel").text = prompt

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
