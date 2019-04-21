extends Node

const PlayerClass = preload("res://Player.gd")
const PromptClass = preload("res://Prompt.gd")

enum SCREENS {
	TITLE_SCREEN = 1
	SETUP_SCREEN = 2
	LOBBY_SCREEN = 3
	WAIT_SCREEN = 4
	VOTE_SCREEN = 5
	RESULTS_SCREEN = 6
	TOTAL_SCREEN = 7
	CREDITS_SCREEN = 8
}

# TODO: Replace with actual avatars
const AVATARPATHS = [
	"res://Assets/m1.png",			# 0 (ID)
	"res://Assets/m3.png",			# 1
	"res://Assets/m7.png",			# 2
	"res://Assets/m0.png",			# 3
	"res://Assets/m2.png",			# 4
	"res://Assets/m4.png",			# 5
	"res://Assets/m5.png",			# 6
	"res://Assets/m6.png",			# 7
]
const DEFAULTAVATAR = "res://Assets/Emojis/blank.png"	# Default transparent 

const MAXPLAYERS = 8
const MAXROUNDS = 3