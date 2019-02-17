extends Node2D

const PlayerClass = preload("res://Player.gd")

onready var p1 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P1
onready var p2 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P2
onready var p3 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P3
onready var p4 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P4
onready var p5 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P5
onready var p6 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P6
onready var p7 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P7
onready var p8 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P8

onready var pDisplays = [p1, p2, p3, p4, p5, p6, p7, p8] # GUI representing each player

var avatarList = [] # Stores the avatars, indexed by Player.AvatarID
var playerInfo = [] # Stores the playerID, username, and avatarIndex of each player

### DEBUG/TESTING ###
func _debug():
	var ids = [400025, 2111079, 90001]
	
	randomize()
	
	for x in ids:
		add_player_id(x)
		update_player_display(x, "%d" % x, randi() % 8)
		pass
	
	return

func _ready():
	avatarSetup()
	
	p1.get_node("Name").text = "Octosquid"
	
	for x in range(0, 8):
		pDisplays[x].update_player("Player %d" % (x + 1), avatarList[x])
		pDisplays[x].hide()
	
	_debug()
	
	### DEBUG ###
	var playerTest = self.get_child(1)
	print (playerTest)
	
	return

func _process(delta):
	
	pass

func avatarSetup(): # loads the avatars in use
	avatarList.resize(8)
	for x in range (8):
		avatarList[x] = load("res://Assets/m%d.png" % x)
	
	#avatarList[2] = preload("res://Assets/m2.png")
	pass
	
func update_player_display(playerID, username, avatarIndex):
	
	# find player
	var index = playerInfo.find(playerID)
	
	if (index == -1): # no player with that ID was found
		return -1
		
	pDisplays[index].update_player(username, avatarList[avatarIndex])
	
	return 0
	pass

# Adds a player into the playerInfo array, 
func add_player_id(playerID):
	var index = playerInfo.size()
	
	if (index < 8):
		playerInfo.append(playerID)
		pDisplays[index].show()
	else:
		return 1 # TODO: put in audience etc.
	
	return 0
	