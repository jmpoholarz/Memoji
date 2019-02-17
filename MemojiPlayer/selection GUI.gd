extends Container

signal change_icon(iconId)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	var textRect = get_node("MarginContainer/HBoxContainer/VBoxContainer/VBoxContainer/HBoxContainer/TextureRect")
	connect("change_icon", textRect, "on_change_icon")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_Button_pressed(id):
	emit_signal("change_icon", id)
