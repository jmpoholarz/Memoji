extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("JoinButton").connect("pressed", self, "_on_JoinMeButton_pressed")

func _on_JoinMeButton_pressed():
	var roomCode = get_node("RoomCodeLineEdit").text
	
	if roomCode.length() == 4:
		var check = true
		for i in range(0,4):
			if (roomCode[i].is_valid_integer()):
				print("hello")
				check = false
				break
		
		if check == true:
			get_node("InstructionsLabel").text = roomCode
			get_tree().change_scene("res://UserInformationScreen.tscn")
		else:
			get_node("RoomCodeInvalidLengthPopup").popup()
	else:
		get_node("RoomCodeInvalidLengthPopup").popup()
	
	
	
	
