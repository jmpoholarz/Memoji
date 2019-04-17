tool
extends PopupPanel

export(String) var label_text = "Sample text."

onready var _Label = $Label

func _ready():
	_Label.text = label_text

func _on_ErrorPopup_about_to_show():
	_Label.text = label_text