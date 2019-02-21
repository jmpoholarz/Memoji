extends Container

signal connectToServer()
signal messageServer(msg)
signal changeScreen(screen)

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass


func _on_Button_pressed():
	emit_signal("connectToServer")
	$"MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Connecting Label".visible = true
	$MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Players/MarginContainer9/Button.disabled = true
	#emit_signal("changeScreen", 2)

func show_connection_error():
	$ConnectionErrorPopup.popup()
	$"MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Connecting Label".visible = false
	$MarginContainer2/MarginContainer3/VBoxContainer/VBoxContainer2/VBoxContainer2/Players/MarginContainer9/Button.disabled = false
