extends VBoxContainer

var playerID = null
var avatarList = []
var progress = 0
var maxPrompts

func _ready():
	# TODO: Replace Placeholder
	avatarList.resize(8)
	avatarList[0] = preload("res://Assets/m1.png")
	avatarList[1] = preload("res://Assets/m3.png")
	avatarList[2] = preload("res://Assets/m7.png")
	avatarList[3] = preload("res://Assets/m0.png")
	avatarList[4] = preload("res://Assets/m2.png")
	avatarList[5] = preload("res://Assets/m4.png")
	avatarList[6] = preload("res://Assets/m5.png")
	avatarList[7] = preload("res://Assets/m6.png")
	
	$PlayerDisplay.hide()
	$Checkmark.hide()
	pass

func link_player(player):
	self.playerID = player.playerID
	update_from_player(player)
	$PlayerDisplay.show()
	$Checkmark.hide()
	
func update_from_player(player):
	$PlayerDisplay.update_player(player.username, avatarList[player.avatarID])
	
func show_confirmation():
	$Checkmark.show()

func record_answer():
	progress += 1;
	if (progress >= 2): show_confirmation()

func reset():
	playerID = null
	$PlayerDisplay.hide()
	$Checkmark.hide()