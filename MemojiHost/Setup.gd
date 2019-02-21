extends Container

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

onready var codeLabel =  $MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer4/HBoxContainer/ABCDcode

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func update_lettercode(code):
	codeLabel.text = code

func _on_Button_pressed():
	emit_signal("changeScreen", 3)

func _on_RequestCode_pressed():
	var request = { "messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE, "letterCode": "????" }
	emit_signal("messageServer", request)
