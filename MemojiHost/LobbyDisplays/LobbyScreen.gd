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
var linkedIDs = [] # Stores the playerID

### DEBUG/TESTING ###
func _debug():
	var ids = [400025, 2111079, 90001]
	
	randomize()
	"""
	for x in ids:
		add_player_id(x)
		update_player_status2(x, "%d" % x, randi() % 8)
		pass
	for y in range(3, 8):
		add_player_id(0)
	"""
	
	var sample1 = PlayerClass.new()
	sample1.playerID = 2005
	sample1.username = "Archie"
	sample1.avatarID = 6
	sample1.isPlayer = 1
	
	add_player_id(sample1.playerID)
	update_player_status(sample1)
	
	return

func _ready():
	avatarSetup()
	
	p1.get_node("Name").text = "Octosquid"
	
	#for x in range(0, 8):
	#	pDisplays[x].update_player("Player %d" % (x + 1), avatarList[x])
		
	### DEBUG ###
	_debug()
	
	return

func _process(delta):
	
	pass

func avatarSetup(): # loads the avatars in use
	avatarList.resize(8)
	for x in range (8):
		avatarList[x] = load("res://Assets/m%d.png" % x)
	
	#avatarList[2] = preload("res://Assets/m2.png")
	pass
	
func update_player_status2(playerID, username, avatarID):
	
	# find player
	var index = linkedIDs.find(playerID)
	
	if (index == -1): # no player with that ID was found
		return -1
		
	pDisplays[index].update_player(username, avatarList[avatarID])
	
	return 0
func update_player_status(playerObj):
	
	var index = linkedIDs.find(playerObj.playerID)
	
	if (index == -1):
		return -1
	
	update_display(index, playerObj)
	
	return 0

# Adds a player into the linkedIDs array, 
func add_player_id(playerID):
	var index = linkedIDs.size()
	
	if (index < 8):
		linkedIDs.append(playerID)
		pDisplays[index].reset()
		pDisplays[index].show()
	else:
		return 1 # TODO: put in audience etc.
	
	return 0
	
# Updates the entire line of player status based on an array
func players_from_list(players): # takes an array of Player Objects
	linkedIDs.clear()
	
	for index in range (players.size()):
		linkedIDs.append(players[index].playerID)
		update_display(index, players[index])
		pass
	
	return

# Makes the display at index show info about the provided player object
func update_display(index, playerObj):
	pDisplays[index].update_player(playerObj.username, avatarList[playerObj.avatarID])
	return