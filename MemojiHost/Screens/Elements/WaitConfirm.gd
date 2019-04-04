extends VBoxContainer

var playerID = null
var avatarList = []
var progress = 0
var maxPrompts

func _ready():
	# TODO: Replace Placeholder
	avatarSetup()
	$PlayerDisplay.hide()
	$Checkmark.hide()
	pass
	
func avatarSetup(): # loads the avatars in use
	avatarList.resize(GlobalVars.MAXPLAYERS)
	for index in range(avatarList.size()):
		avatarList[index] = load(GlobalVars.AVATARPATHS[index])

func link_player(player):
	self.playerID = player.playerID
	update_from_player(player)
	$PlayerDisplay.show()
	$Checkmark.hide()
	
func update_from_player(player):
	$PlayerDisplay.update_player(player.username, player.avatarID)
	
func show_confirmation():
	$Checkmark.show()

func record_answer():
	progress += 1;
	if (progress >= 2): show_confirmation()

func reset():
	playerID = null
	$PlayerDisplay.hide()
	$Checkmark.hide()