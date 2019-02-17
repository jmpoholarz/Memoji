extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var newId = 0
var newName = "name"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func on_change_icon(id):
	newId = id

func on_change_text(newText):
	newName = newText


func _on_TouchScreenButton_pressed():
	print(str(newId) + " " + newName)
