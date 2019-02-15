extends VBoxContainer

var DEFAULT_TEXT = ""
onready var name_label = $Name
onready var avatar_pic = $Icon/Avatar

func _ready():
	name_label.text = DEFAULT_TEXT
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

# Change the avatar and name
func player_update(newName, newAvatar):
	name_label.text = newName
	pass