extends Panel

signal emoji_selected(id)


func _on_ButtonContainer_emoji_button_pressed(id):
	emit_signal("emoji_selected", id)
	#print("Processing signal for id " + str(id) + " in EmojiPalette Parent")