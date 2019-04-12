tool
extends PopupPanel

export(String) var label_text = "Sample text." setget _update_text, _get_text

onready var _Label = $Label

func _ready():
	_Label.text = label_text

func _update_text(new_text):
	if _Label:
		_Label.text = new_text

func _get_text():
	if _Label:
		return _Label.text
	return ""