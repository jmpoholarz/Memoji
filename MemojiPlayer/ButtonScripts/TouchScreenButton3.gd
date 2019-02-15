extends Button

signal icon_select(iconId)
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.connect("icon_select", TextureRect, "on_icon_select")
	self.connect("icon_select", TouchScreenButton, "on_icon_select")
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_TouchScreenButton_pressed():
	emit_signal("icon_select", 3)
