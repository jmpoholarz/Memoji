extends HBoxContainer
# Class that handles visual confirmation of class 
onready var _W1 = $LeftColumn/W1
onready var _W2 = $RightColumn/W2
onready var _W3 = $LeftColumn/W3
onready var _W4 = $RightColumn/W4
onready var _W5 = $LeftColumn/W5
onready var _W6 = $RightColumn/W6
onready var _W7 = $LeftColumn/W7
onready var _W8 = $RightColumn/W8

onready var displays = [_W1, _W2, _W3, _W4, _W5, _W6, _W7, _W8]
var playerCount = 0

func _ready():
	pass

# To be connected to the receivedPlayerAnswer signal by GameStateManager
func on_prompt_answer(playerID, promptID, emojiArray):
	print("DEBUG: Signal Connected")
	for index in range(playerCount):
		if (displays[index].playerID == playerID):
			displays[index].record_answer()
			break
	
	
func update_from_list(players): # Takes an array of Player objects
	playerCount = players.size()
	if (playerCount > 8): playerCount = 8 # make within bounds
	
	for index in range(playerCount):
		displays[index].link_player(players[index])