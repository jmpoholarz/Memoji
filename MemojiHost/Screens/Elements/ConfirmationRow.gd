extends HBoxContainer
# Class that handles visual confirmation of class 
onready var displays = [$W1, $W2, $W3, $W4, $W5, $W6, $W7, $W8]
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