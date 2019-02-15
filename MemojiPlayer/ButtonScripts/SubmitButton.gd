extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var iconNumber = 0
var nameGiven = "name"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func on_icon_select(iconId):
	iconNumber = iconId

func _on_Button_pressed():
	var network = load("res://Singletons/Networking.gd").new()
	network.sendMessageToServer(iconNumber + nameGiven)

func _on_name_changed(newName):
	nameGiven = newName


func _on_TouchScreenButton_pressed():
