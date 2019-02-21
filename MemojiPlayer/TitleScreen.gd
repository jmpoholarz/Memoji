extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal connectToServer()
signal sendMessage(msg)


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
			roomCode = roomCode.to_upper()
			print(roomCode)
			get_node("InstructionsLabel").text = roomCode
			
			var msg = {
				"messageType": MESSAGE_TYPES.PLAYER_CONNECTED,
				"letterCode": roomCode
			}
#			Networking.sendMessageToServer(msg)
			emit_signal("connectToServer")
			yield(get_tree().create_timer(2), "timeout")
			# TODO have some sort of connect message
			emit_signal("sendMessage", msg)
			
			
			#get_tree().change_scene("res://UserInformationScreen.tscn")
		else:
			get_node("RoomCodeInvalidCharacters").popup()
	else:
		get_node("RoomCodeInvalidLengthPopup").popup()
		
func _on_InvalidRoomCode():
	get_node("RoomCodeInvalidCharacters").popup()
	
func show_ServerErrorPopup(text):
	print("in thing")
	$ServerErrorPopup/Label.text = text
	$ServerErrorPopup.popup()
	
	
