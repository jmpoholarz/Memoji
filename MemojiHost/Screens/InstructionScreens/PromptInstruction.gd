extends Panel

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_ProceedButton_pressed():
	emit_signal("updateGameState", "instructionsDone")