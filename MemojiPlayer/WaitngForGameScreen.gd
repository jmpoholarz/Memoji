extends Panel

signal sendMessage(msg)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var roomCode = "????"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func new_room_code(code):
	roomCode = code;

func _on_BackButton_pressed():
	var msg = {"messageType": MESSAGE_TYPES.PLAYER_DISCONNECTED, "letterCode":roomCode}
	emit_signal("sendMessage", msg)
	emit_signal("changeScreen", 1)