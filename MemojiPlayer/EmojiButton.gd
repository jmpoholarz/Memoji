extends Button

signal emoji_button_pressed(id)

var _emoji_id = -1

func set_emoji_id(id):
	_emoji_id = id

func _on_EmojiButton_pressed():
	emit_signal("emoji_button_pressed", _emoji_id)
	print(_emoji_id)
