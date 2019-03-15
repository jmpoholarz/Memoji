extends PanelContainer

export(bool) var is_editable = false

const ROWS = 5
const COLUMNS = 5

var _GridContainer
var _CanvasTileMap
var grid_dict = {}
var currently_selected_emoji_id = -1

func _ready():
	_GridContainer = $GridContainer
	_CanvasTileMap = $CanvasTileMap
	_CanvasTileMap.connect("canvas_clicked", self, "handle_canvas_click")
	setup_grid()

func setup_grid():
	var id = 10010
	for i in range(5):
		for j in range(5):
			var spr = Sprite.new()
			spr.set_scale(Vector2(0.5, 0.5))
			spr.texture = load(EmojiIdToFilename.EmojiIdToFilenameDict[id])
			spr.centered = false
			spr.offset = Vector2(26, 26)
			id += 10
			var cell = TextureRect.new()
			cell.rect_min_size = Vector2(64,64)
			cell.add_child(spr)
			_GridContainer.add_child(cell)
			grid_dict[Vector2(i,j)] = [cell, spr]

func handle_canvas_click(row, column):
	if !is_editable:
		return
	if row < 0 or row >= ROWS or column < 0 or column >= COLUMNS:
		return
	grid_dict[Vector2(row, column)][1].texture = load(EmojiIdToFilename.EmojiIdToFilenameDict[currently_selected_emoji_id])

func update_emoji_selected(new_emoji_id):
	if !is_editable:
		return
	currently_selected_emoji_id = new_emoji_id