extends VBoxContainer

export(int, "left", "right") var wait_screen_column = -1

const LEFT_WAIT_SCREEN_COLUMN = 0
const RIGHT_WAIT_SCREEN_COLUMN = 1
const READY_OFFSET = 32

var playerID = null
var avatarList = []
var progress = 0
var maxPrompts

func _ready():
	# TODO: Replace Placeholder
	avatarSetup()
	hide()
	$PlayerDisplay.hide()
	#$Checkmark.hide()
	
	
func avatarSetup(): # loads the avatars in use
	avatarList.resize(GlobalVars.MAXPLAYERS)
	for index in range(avatarList.size()):
		avatarList[index] = load(GlobalVars.AVATARPATHS[index])

func link_player(player):
	self.playerID = player.playerID
	update_from_player(player)
	show()
	$PlayerDisplay.show()
	$Checkmark.hide()
	
func update_from_player(player):
	$PlayerDisplay.update_player(player.username, player.avatarID)
	
func show_confirmation():
	#$Checkmark.show()
	if wait_screen_column == LEFT_WAIT_SCREEN_COLUMN:
		rect_position.x += READY_OFFSET
		$PlayerDisplay.animate_avatar(GlobalVars.AVATAR_EMOTIONS.HAPPY)
	elif wait_screen_column == RIGHT_WAIT_SCREEN_COLUMN:
		rect_position.x -= READY_OFFSET
		$PlayerDisplay.animate_avatar(GlobalVars.AVATAR_EMOTIONS.HAPPY)

func record_answer():
	progress += 1;
	if (progress >= 2): show_confirmation()

func reset():
	playerID = null
	hide()
	$PlayerDisplay.hide()
	$Checkmark.hide()