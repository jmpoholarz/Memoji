extends TextEdit

signal name_changed(newName)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.connect("name_changed", TouchScreenButton, "on_name_changed")


#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass




func _on_TextEdit_text_changed():
	emit_signal("name_changed",TextEdit.text)
