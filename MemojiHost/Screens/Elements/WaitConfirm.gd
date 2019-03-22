extends VBoxContainer

var playerID

func _ready():
	$PlayerDisplay.hide()
	$Checkmark.hide()
	pass

func linkToPlayer(player):
	self.playerID = player.playerID
	update_from_player(player)
	$PlayerDisplay.show()
	
func update_from_player(player):
	$Player.update_player(player.username, player.avatarID)
	
func show_confirmation():
	$Checkmark.show()

func reset():
	$PlayerDisplay.hide()
	$Checkmark.hide()