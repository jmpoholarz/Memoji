extends Node2D

signal messageServer(msg)
signal changeScreen(screen)

const PlayerClass = preload("res://Player.gd")

onready var p1 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P1
onready var p2 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P2
onready var p3 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P3
onready var p4 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P4
onready var p5 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P5
onready var p6 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P6
onready var p7 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P7
onready var p8 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P8
onready var audienceDisplay = $Foreground/Content/Lines/TopLine/Statuses/AudienceStatus/Audience
onready var codeDisplay = $Foreground/Content/Lines/BottomLine/ABCDcode # audience number

onready var pDisplays = [p1, p2, p3, p4, p5, p6, p7, p8] # GUI representing each player

var avatarList = [] # Stores the avatars, indexed by Player.AvatarID
var linkedIDs = [] # Stores the playerID

### DEBUG/TESTING ###
func _debug():
	var ids = [400025, 2111079, 90001]
	
	randomize()
	
	for x in ids:
		add_player_id(x)
		update_player_status2(x, "%d" % x, randi() % 8)
		pass
	for y in range(3, 8):
		add_player_id(0)
	
	
	var sample1 = PlayerClass.new()
	sample1.playerID = 2005
	sample1.username = "Archie"
	sample1.avatarID = 6
	sample1.isPlayer = 1
	var sample2 = PlayerClass.new()
	sample2.playerID = 1996
	sample2.username = "Lyra"
	sample2.avatarID = 7
	sample2.isPlayer = 1
	var sample3 = PlayerClass.new()
	sample3.playerID = 2017
	sample3.username = "Larry"
	sample3.avatarID = 1
	sample3.isPlayer = 1
	var sample4 = PlayerClass.new()
	sample4.playerID = 2012
	sample4.username = "Alex"
	sample4.avatarID = 0
	sample4.isPlayer = 1
	var sample5 = PlayerClass.new()
	sample5.playerID = 9001
	sample5.username = "Goku"
	sample5.avatarID = 2
	sample5.isPlayer = 1
	
	var players = [sample1, sample2, sample3, sample4, sample5]
	
	add_player_id(sample1.playerID)
	update_player_status(sample1)
	
	update_from_list(players)
	
	return

func _ready():
	avatarSetup()
	
	#for x in range(0, 8):
	#	pDisplays[x].update_player("Player %d" % (x + 1), avatarList[x])
		
	### DEBUG ###
	#_debug()
	
	return

func _process(delta):
	
	pass

func avatarSetup(): # loads the avatars in use
	avatarList.resize(8)
	for x in range (8):
		avatarList[x] = load("res://Assets/m%d.png" % x)
	return

# Old function
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
func update_from_list(players): # takes an array of Player Objects
	linkedIDs.clear()
	
	var playerCount = players.size()
	if (playerCount > 8): playerCount = 8 # make within bounds
	
	for index in range(playerCount):
		add_player_id(players[index].playerID)
		update_display(index, players[index])
		pass
	for index in range(playerCount, 8):
		pDisplays[index].hide()
	
	return

# Makes the display at index show info about the provided player object
func update_display(index, playerObj):
	pDisplays[index].update_player(playerObj.username, avatarList[playerObj.avatarID])
	return

func update_lettercode(code):
	codeDisplay.text = code
	return

func _on_StartButton_pressed():
	pass # replace with function body
