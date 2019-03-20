extends Node

const PlayerClass = preload("res://Player.gd")
const PromptClass = preload("res://Prompt.gd")

enum SCREENS {
	TITLE_SCREEN = 1
	SETUP_SCREEN = 2
	LOBBY_SCREEN = 3
	WAIT_SCREEN = 4
	RESULTS_SCREEN = 5
}