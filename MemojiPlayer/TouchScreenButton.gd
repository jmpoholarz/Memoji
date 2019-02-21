extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

#storage for the avatar id and the player name
var newId = 0
var newName = "name"

signal sendMessage(msg)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

#store the new avatar id
func on_change_icon(id):
	newId = id

#store the new player name when changed
func on_change_text(newText):
	name = newText


func _on_Button_pressed():
	if name.length() > 0:
		#name = name.to_upper()
		print(name)
#		get_node("TestLabel").text = name

		var msg = {
			"messageType": MESSAGE_TYPES.PLAYER_USERNAME_AND_AVATAR,
			"username": name,
			"avatarIndex": newId
		}
		emit_signal("sendMessage",msg)
	else:
		get_node("NameNullPopup").popup()
	
	#validate that the correct id and name are stored
	print(str(newId) + " " + name)
	

