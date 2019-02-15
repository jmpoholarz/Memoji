extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("DoneButton").connect("pressed", self, "_on_DoneButton_pressed")


func _on_DoneButton_pressed():
	var name = get_node("NameLineEdit").text
	get_node("TestLabel").text = name
	
	