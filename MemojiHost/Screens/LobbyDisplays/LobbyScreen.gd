extends Node2D

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)
signal startGame()

onready var p1 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P1
onready var p2 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P2
onready var p3 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P3
onready var p4 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P4
onready var p5 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P5
onready var p6 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P6
onready var p7 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P7
onready var p8 = $Foreground/Content/Lines/TopLine/Statuses/PlayerStatus/P8
onready var audienceLabel = $Foreground/Content/Lines/TopLine/Statuses/AudienceStatus/Audience
onready var codeLabel = $Foreground/Content/Lines/BottomLine/ABCDcode # audience number

onready var pDisplays = [p1, p2, p3, p4, p5, p6, p7, p8] # GUI representing each player

var avatarList = [] # Stores the avatars, indexed by Player.AvatarID
var linkedIDs = [] # Stores the playerID

func _ready():
	avatarSetup()
	
	codeLabel.text = "????"
	emit_signal("updateGameState", "code")

func avatarSetup(): # loads the avatars in use
	avatarList.resize(8)
	# TODO: replace placeholders
	## Temporarily used to match client placeholder ##
	avatarList[0] = preload("res://Assets/m1.png")
	avatarList[1] = preload("res://Assets/m3.png")
	avatarList[2] = preload("res://Assets/m7.png")
	avatarList[3] = preload("res://Assets/m0.png")
	avatarList[4] = preload("res://Assets/m2.png")
	avatarList[5] = preload("res://Assets/m4.png")
	avatarList[6] = preload("res://Assets/m5.png")
	avatarList[7] = preload("res://Assets/m6.png")

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

# Makes the display at index show info about the provided player object
func update_display(index, playerObj):
	pDisplays[index].update_player(playerObj.username, avatarList[playerObj.avatarID])

func update_lettercode(code):
	codeLabel.update_code(code)

func update_audience(count):
	audienceLabel.update_count(count)

func _on_StartButton_pressed():
	# Do logic in GameStateManager
	# Check for if there are enough players joined
	# Check for players are connected but no avatar is selected
	
	# Create message to send to players that game is starting
	# Send message to server
	
	# Get prompts -> PromptManager, PromptGenerator
	# Create message dictionary
	# emit_signal("sendMessage", msg) to server
	# emit_signal("changeScreen", GlobalVars.WAIT_SCREEN)
	emit_signal("startGame")
	pass # replace with function body

func _on_ExitButton_pressed():
	emit_signal("updateGameState", "disconnectLobby")
