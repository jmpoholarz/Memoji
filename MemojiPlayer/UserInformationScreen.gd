extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
signal sendMessage(message)

func _ready():
	get_node("DoneButton").connect("pressed", self, "_on_DoneButton_pressed")
	$"Panel/selection GUI".connect("sendMessage", self, "sendMessage")

#
func _on_InvalidName():
	get_node("NameNullPopup").popup()
	
func sendMessage(message):
	emit_signal("sendMessage", message)

func change_name_and_icon(pName, icon):
	var gui = get_node("Panel/selection GUI")
	gui._on_Button_pressed(icon)
	gui.changeText(pName)