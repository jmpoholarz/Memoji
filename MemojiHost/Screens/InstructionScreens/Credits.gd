extends Panel

signal restart()
signal newGame()


func _on_SameButton_pressed():
	#restart the same game
	emit_signal("restart")


func _on_NewButton_pressed():
	#begin a new game
	emit_signal("newGame")
