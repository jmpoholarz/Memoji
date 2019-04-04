extends VBoxContainer

onready var name_label = $Name
onready var avatar_pic = $Icon/Avatar

const DEFAULT_TEXT = "..."
var DEFAULT_AVATAR = load(GlobalVars.DEFAULTAVATAR)
var avatarList = []

func _ready():
	avatarSetup()
	reset()

func avatarSetup(): # loads the avatars in use
	avatarList.resize(GlobalVars.MAXPLAYERS)
	for index in range(avatarList.size()):
		avatarList[index] = load(GlobalVars.AVATARPATHS[index])

func reset():
	name_label.text = DEFAULT_TEXT
	avatar_pic.texture = DEFAULT_AVATAR
	
# Change the avatar and name
func update_player(newName, avatarID):
	if (newName != null):
		name_label.text = newName
	else:
		name_label.text = DEFAULT_TEXT
		
	if (avatarID != null):
		avatar_pic.texture = avatarList[avatarID]
	else:
		avatar_pic.texture = DEFAULT_AVATAR
