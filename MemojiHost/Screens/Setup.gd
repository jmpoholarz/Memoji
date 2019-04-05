extends Container

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

onready var codeLabel = $MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer4/HBoxContainer/ABCDcode
var repeatLocation = "MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer4/HBoxContainer3/RepeatCheck"
var toggleLocation = "MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer4/HBoxContainer2/InstructionsCheck"

func _ready():
	$MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Players/MarginContainer9/Button.disabled = true
	pass

func update_lettercode(code):
	codeLabel.text = code
	$MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Players/MarginContainer9/Button.disabled = false

func _on_Button_pressed():
	emit_signal("changeScreen", GlobalVars.LOBBY_SCREEN)

func _on_RequestCode_pressed():
	var request = { "messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE, "letterCode": "????" }
	emit_signal("messageServer", request)


func _on_InstructionsCheck_toggled(button_pressed):
	var repeat = get_node(repeatLocation)
	if button_pressed:
		repeat.pressed = false
		repeat.visible = true
	else:
		repeat.visible = false
		repeat.pressed = false
