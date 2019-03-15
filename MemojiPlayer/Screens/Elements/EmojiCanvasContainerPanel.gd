extends Panel

var _EmojiPalette
var _CurrentEmojiSelectedPreview
var _EmojiCanvas

var current_emoji_id = -1

func _ready():
	_EmojiPalette = $VBoxContainer/MarginContainer/EmojiPalette
	_CurrentEmojiSelectedPreview = $VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/CurrentEmojiSelectedPreview
	_EmojiCanvas = $VBoxContainer/HBoxContainer/EmojiCanvas
	
	_EmojiPalette.connect("emoji_selected", self, "_update_emoji_preview")

func _update_emoji_preview(new_id):
	current_emoji_id = new_id
	_EmojiCanvas.update_emoji_selected(new_id)
	var path = EmojiIdToFilename.EmojiIdToFilenameDict[new_id]
	_CurrentEmojiSelectedPreview.texture = load(path)