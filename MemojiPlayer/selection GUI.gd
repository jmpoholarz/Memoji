extends Container

#signals for when the player's icon or name changes
signal change_icon(iconId)
signal change_text(text)
signal sendMessage(message)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	#get the texture rectangle and the submit button since they need to get signals
	var textRect = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect")
	var textSubmit = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer3/MarginContainer/TouchScreenButton")
	#connect signals to texture rectangle and submit button
	connect("change_icon", textRect, "on_change_icon")
	connect("change_icon", textSubmit, "on_change_icon")
	connect("change_text", textSubmit, "on_change_text")
	textSubmit.connect("sendMessage", self, "textSubmitToServer")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

#When an avatar is selected, signal the texture rectangle to update with the id of the avatar
func _on_Button_pressed(id):
	emit_signal("change_icon", id)

#when the player's name is changed, send that information to the submit button to be stored
func _on_TextEdit_text_changed():
	var textBox = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextEdit")
	
	emit_signal("change_text", textBox.text)

func changeText(text):
	var textBox = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextEdit")
	textBox.text = text
	emit_signal("change_text", text)

func textSubmitToServer(message):
	print("Submitting text to server! . . . " + str(message))
	emit_signal("sendMessage", message)