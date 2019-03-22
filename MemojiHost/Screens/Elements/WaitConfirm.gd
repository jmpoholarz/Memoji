extends VBoxContainer

var playerID = null

func _ready():
	$PlayerDisplay.hide()
	$Checkmark.hide()
	pass

func link_player(player):
	self.playerID = player.playerID
	update_from_player(player)
	$PlayerDisplay.show()
	$Checkmark.hide()
	
func update_from_player(player):
	$Player.update_player(player.username, player.avatarID)
	
func show_confirmation():
	$Checkmark.show()

func reset():
	playerID = null
	$PlayerDisplay.hide()
	$Checkmark.hide()