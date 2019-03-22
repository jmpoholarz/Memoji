extends Node

const PlayerClass = preload("res://Player.gd")
const PromptClass = preload("res://Prompt.gd")

enum SCREENS {
	TITLE_SCREEN = 1
	SETUP_SCREEN = 2
	LOBBY_SCREEN = 3
	WAIT_SCREEN = 4
	RESULTS_SCREEN = 5
	TOTAL_SCREEN = 6
}

# 3 players:
#	prompts = 6 (2 per player)
#	<1, 2>x2, <1, 3>x2
#	<2, 3>x2

# 4 players:
#	prompts = 6 (3 per player)
#	<1, 2>, <1, 3>, <1, 4>
#	<2, 3>, <2, 4>
#	<3, 4>

const three_players = [6, 1, 2, 1, 3, 2, 3]
const four_players = [6, 1, 2, 1, 3, 1, 4, 2, 3, 2, 4, 3, 4]