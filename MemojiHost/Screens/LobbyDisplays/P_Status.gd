extends VBoxContainer

const DEFAULT_TEXT = "..."
const DEFAULT_AVATAR = preload("res://icon.png")

onready var name_label = $Name
onready var avatar_pic = $Icon/Avatar

func _ready():
	name_label.text = DEFAULT_TEXT
	self.hide()
	pass

func reset():
	name_label.text = DEFAULT_TEXT
	avatar_pic.texture = DEFAULT_AVATAR
	
# Change the avatar and name
func update_player(newName, newAvatar):
	name_label.text = newName
	avatar_pic.texture = newAvatar
	pass