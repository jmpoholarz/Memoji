extends Label

func _ready():
	self.text = "????"
	pass
	
func update_code(var newCode):
	self.text = newCode
	self.show()
