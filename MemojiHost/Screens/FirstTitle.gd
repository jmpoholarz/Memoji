extends Panel

signal connectToServer()
signal messageServer(msg)
signal changeScreen(screen)

onready var _ConnectingLabel = $VBoxContainer/ConnectingLabel
onready var _Button = $VBoxContainer/ConnectButton


func _on_Button_pressed():
	emit_signal("connectToServer")
	_ConnectingLabel.visible = true
	_Button.disabled = true
	#emit_signal("changeScreen", 2)

func show_connection_error():
	$ConnectionErrorPopup.popup()
	_ConnectingLabel.visible = false
	_Button.disabled = false
