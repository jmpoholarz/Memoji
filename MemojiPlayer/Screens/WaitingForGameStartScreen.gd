extends Panel

signal sendMessage(msg)
signal disconnectFromHost()
signal changeScreen(screen)

var roomCode = "????"

onready var _BackButton = $VBoxContainer/HBoxContainer/VBoxContainer/BackButton

func hide_back_button():
	_BackButton.visible = false

func new_room_code(code):
	roomCode = code;

func _on_BackButton_pressed():
	emit_signal("changeScreen", 2)

func _on_DisconnectButton_pressed():
	var msg = {"messageType": MESSAGE_TYPES.PLAYER_DISCONNECTED, "letterCode":roomCode}
	emit_signal("sendMessage", msg)
	emit_signal("disconnectFromHost")
	emit_signal("changeScreen", 1)
