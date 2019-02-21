extends Container

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

onready var codeLabel =  $MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer4/HBoxContainer/ABCDcode

func _ready():
	$MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Players/MarginContainer9/Button.disabled = true
	pass

func update_lettercode(code):
	codeLabel.text = code
	$MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Players/MarginContainer9/Button.disabled = false

func _on_Button_pressed():
	emit_signal("changeScreen", 3)

func _on_RequestCode_pressed():
	var request = { "messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE, "letterCode": "????" }
	emit_signal("messageServer", request)
