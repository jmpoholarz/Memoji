extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"


signal changeScreen(screen)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_ProceedButton_pressed():
	emit_signal("changeScreen", GlobalVars.MULTI_VOTE_SCREEN)