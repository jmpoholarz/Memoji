extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#signal sendMessage(msg)

func _ready():
	get_node("DoneButton").connect("pressed", self, "_on_DoneButton_pressed")

#
func _on_DoneButton_pressed():
#	var name = get_node("NameLineEdit").text
#
#	if name.length() > 0:
#		name = name.to_upper()
#		print(name)
#		get_node("TestLabel").text = name
#
#		var msg = {
#			"messageType": MESSAGE_TYPES.PLAYER_USERNAME_AND_AVATAR,
#			"username": name,
#			"avatarIndex": 1
#		}
#		emit_signal("sendMessage",msg)
#
#	else:
#		get_node("NameNullPopup").popup()
#
func _on_InvalidName():
	get_node("NameNullPopup").popup()
	
	