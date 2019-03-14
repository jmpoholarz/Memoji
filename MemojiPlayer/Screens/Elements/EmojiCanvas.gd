extends Panel

var _GridContainer

func _ready():
	_GridContainer = $GridContainer
	setup_grid()


func setup_grid():
	for i in range(25):
		var spr = Sprite.new()
		spr.set_scale(Vector2(0.5, 0.5))
		spr.texture = load("res://Assets/FoodIcon.png")
		
		var cell = TextureRect.new()
		cell.rect_min_size = Vector2(44,44)
		cell.add_child(spr)
		_GridContainer.add_child(cell)
