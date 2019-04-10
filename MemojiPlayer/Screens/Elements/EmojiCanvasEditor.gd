extends Control

onready var _EmojiCanvas = $EmojiCanvasContainerPanel/VBoxContainer/HBoxContainer/EmojiCanvas
 

func get_emojis():
	return _EmojiCanvas.encode_emojis()

func reset_canvas():
	_EmojiCanvas.clear_grid()