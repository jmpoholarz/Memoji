extends Panel

onready var _EmojiPalette = $VBoxContainer/MarginContainer/EmojiPalette
onready var _CurrentEmojiSelectedPreview = $VBoxContainer/HBoxContainer/VBoxContainer/CenterContainer/CurrentEmojiSelectedPreview
onready var _EmojiCanvas = $VBoxContainer/HBoxContainer/EmojiCanvas

var current_tool_selected = "add"
var current_emoji_id = 10000

func _ready():
	_EmojiPalette.connect("emoji_selected", self, "_on_new_emoji_selected")
	_EmojiCanvas.connect("emoji_grabbed", self, "_on_new_emoji_selected")

func _update_emoji_preview(new_id):
	current_emoji_id = new_id
	_EmojiCanvas.update_emoji_selected(new_id)
	# Update preview
	var path = EmojiIdToFilename.EmojiIdToFilenameDict[new_id]
	_CurrentEmojiSelectedPreview.texture = load(path)

func _on_new_emoji_selected(new_id):
	_update_emoji_preview(new_id)
	# Force back to add tool
	_on_tool_changed("add")
	$VBoxContainer/HBoxContainer/VBoxContainer/AddButton.pressed = true

func _on_tool_changed(new_tool):
	current_tool_selected = new_tool
	_EmojiCanvas.update_tool_selected(new_tool)