extends Label

func _ready():
	reset()
	pass

func reset():
	self.text = "No Audience"
	self.show()
	return

func update_count(num):
	self.text = "%d Audience Members" % num
	self.show()
	return