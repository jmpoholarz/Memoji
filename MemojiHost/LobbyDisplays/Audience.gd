extends Label

func _ready():
	reset()
	pass

func reset():
	self.text = "No Audience"
	self.show()
	return

func update_count(count):
	self.text = "%d Audience Members" % count
	self.show()
	return