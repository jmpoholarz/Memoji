extends Container

signal messageServer(msg)
signal changeScreen(screen)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _on_Button_pressed():
	emit_signal("changeScreen", 3)
