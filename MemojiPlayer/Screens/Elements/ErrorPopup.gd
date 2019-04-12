tool
extends PopupPanel

export(String) var label_text = "Sample text." setget _set_label_text, _get_label_text

onready var _Label = $Label

func _set_label_text(new_text):
	label_text = new_text

func _get_label_text():
	return label_text

func _on_ErrorPopup_about_to_show():
	_Label.text = label_text