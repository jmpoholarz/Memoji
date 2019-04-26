extends Panel

signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

func _on_ProceedButton_pressed():
	emit_signal("updateGameState", "instructionsDone")
