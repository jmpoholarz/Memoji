extends Panel

signal sendMessage(msg)
signal disconnectFromHost()
signal changeScreen(screen)

var roomCode = "????"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func new_room_code(code):
	roomCode = code;

func _on_BackButton_pressed():
	emit_signal("changeScreen", 2)

func _on_DisconnectButton_pressed():
	var msg = {"messageType": MESSAGE_TYPES.PLAYER_DISCONNECTED, "letterCode":roomCode}
	emit_signal("sendMessage", msg)
	emit_signal("changeScreen", 1)
	emit_signal("disconnectFromHost")
