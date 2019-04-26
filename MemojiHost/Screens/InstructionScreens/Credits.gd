extends Panel

signal restart()
signal newGame()
signal messageServer(msg)


func _on_SameButton_pressed():
	#restart the same game
	var message = {
		"messageType": MESSAGE_TYPES.HOST_NEW_GAME
	}
	emit_signal("restart")
	emit_signal("messageServer", message)


func _on_NewButton_pressed():
	#begin a new game
	emit_signal("newGame")
