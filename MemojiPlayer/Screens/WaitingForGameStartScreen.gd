extends Panel

signal sendMessage(msg)
signal disconnectFromHost()
signal changeScreen(screen)

onready var _BackButton = $VBoxContainer/HBoxContainer/VBoxContainer/BackButton

func hide_back_button():
	_BackButton.visible = false

func _on_BackButton_pressed():
	emit_signal("changeScreen", 2)

func _on_DisconnectButton_pressed():
	var msg = {"messageType": MESSAGE_TYPES.PLAYER_DISCONNECTED}
	emit_signal("sendMessage", msg)
	emit_signal("disconnectFromHost")
	emit_signal("changeScreen", 1)
