extends Container

signal change_icon(iconId)
signal change_text(text)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var textRect = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect")
	var textSubmit = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer3/MarginContainer/TouchScreenButton")
	connect("change_icon", textRect, "on_change_icon")
	connect("change_icon", textSubmit, "on_change_icon")
	connect("change_text", textSubmit, "on_change_text")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Button_pressed(id):
	emit_signal("change_icon", id)


func _on_TextEdit_text_changed():
	var textBox = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextEdit")
	emit_signal("change_text", textBox.text)