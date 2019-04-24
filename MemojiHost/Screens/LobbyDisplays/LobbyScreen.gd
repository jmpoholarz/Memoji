extends Panel

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)
signal startGame()

onready var p1 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow1/P1
onready var p2 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow1/P2
onready var p3 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow1/P3
onready var p4 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow1/P4
onready var p5 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow2/P5
onready var p6 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow2/P6
onready var p7 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow2/P7
onready var p8 = $VBoxContainer/Content/Lines/TopLine/Statuses/PlayersRow2/P8
onready var _AudienceLabel = $VBoxContainer/Content/Lines/TopLine/Statuses/Audience
onready var _CodeLabel = $VBoxContainer/Content/Lines/BottomLine/ABCDcode
onready var pDisplays = [p1, p2, p3, p4, p5, p6, p7, p8] # GUI representing each player
onready var _NotEnoughPlayers = $NotEnoughPlayersPopup
onready var _NotAllPlayersHaveAvatar = $NotAllPlayersHaveAvatar
onready var _TopLine = $VBoxContainer/Content/Lines/TopLine
onready var _ContentContainer = $VBoxContainer/Content
onready var _StartButton = $VBoxContainer/Content/Lines/TopLine/VBoxContainer/StartButton
onready var _ExitButton = $VBoxContainer/Content/Lines/TopLine/VBoxContainer/ExitButton

var linkedIDs = [] # Stores the playerID


func _ready():
	_CodeLabel.text = "????"
	emit_signal("updateGameState", "code")

# Old function
func update_player_status2(playerID, username, avatarID):
	# find player
	var index = linkedIDs.find(playerID)
	if (index == -1): # no player with that ID was found
		return -1
	pDisplays[index].update_player(username, avatarID)
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
	pDisplays[index].update_player(playerObj.username, playerObj.avatarID)

func update_lettercode(code):
	_CodeLabel.update_code(code)

func update_audience(count):
	_AudienceLabel.update_count(count)

func _on_StartButton_pressed():
	# Disable button
	_StartButton.disabled = true
	emit_signal("updateGameState", "startGame")

func _on_ExitButton_pressed():
	_ExitButton.disabled = true
	emit_signal("updateGameState", "disconnectLobby")
	
func showNotEnoughPlayers():
	_NotEnoughPlayers.popup()

func showNotAllPlayersHaveAvatar():
	_NotAllPlayersHaveAvatar.popup()
