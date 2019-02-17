extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("DoneButton").connect("pressed", self, "_on_DoneButton_pressed")


func _on_DoneButton_pressed():
	var name = get_node("NameLineEdit").text
	var check = true
	for i in range(0,name.length()):
		if (name[i].is_valid_integer()):
			print("hello")
			check = false
			break
		
	if check == true:
		name = name.to_upper()
		print(name)
		get_node("TestLabel").text = name
			
		var msg = {
			"messageType": MESSAGE_TYPES.PLAYER_USERNAME_AND_AVATAR,
			"letterCode": roomCode,
			
		}
		
	get_node("TestLabel").text = name
	
	