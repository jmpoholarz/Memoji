extends Panel

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

onready var _CodeLabel = $VBoxContainer/SettingsContainer/CodeContainer/ABCDcode
onready var _RepeatToggle = $VBoxContainer/SettingsContainer/RepeatCheck
onready var _InstructionToggle = $VBoxContainer/SettingsContainer/InstructionsCheck
onready var _PlayButton = $VBoxContainer/PlayButton

var instructionState = true
var repeatState = false

func _ready():
	_PlayButton.disabled = true
	

func update_lettercode(code):
	_CodeLabel.text = code
	_PlayButton.disabled = false

func _on_PlayButton_pressed():
	emit_signal("changeScreen", GlobalVars.LOBBY_SCREEN)

func _on_RequestCodeButton_pressed():
	var request = { "messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE, "letterCode": "????" }
	emit_signal("messageServer", request)


func _on_InstructionsCheck_toggled(button_pressed):
	instructionState = !instructionState
	if instructionState:
		repeatState = false
		_RepeatToggle.pressed = false
		_RepeatToggle.visible = true
	else:
		repeatState = false
		_RepeatToggle.visible = false
		_RepeatToggle.pressed = false

func getInstructionState():
	return instructionState

func getRepeatState():
	return repeatState
