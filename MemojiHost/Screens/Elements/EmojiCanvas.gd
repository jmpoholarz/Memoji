extends PanelContainer

export(bool) var is_editable = false

signal emoji_grabbed(id)

const ROWS = 5
const COLUMNS = 5

var _GridContainer
var _CanvasTileMap
var grid_dict = {}
var currently_selected_emoji_id = 10000
var currently_selected_tool = "add"

var saved_encoding = []

func _ready():
	_GridContainer = $GridContainer
	_CanvasTileMap = $CanvasTileMap
	_CanvasTileMap.connect("canvas_clicked", self, "handle_canvas_click")
	setup_grid()

func setup_grid():
	var id = 10000
	for i in range(5):
		for j in range(5):
			var filename = EmojiIdToFilename.EmojiIdToFilenameDict[id]
			var spr = Sprite.new()
			spr.set_scale(Vector2(0.5, 0.5))
			spr.texture = load(filename)
			spr.centered = false
			spr.offset = Vector2(26, 26)
			#id += 10
			var cell = TextureRect.new()
			cell.rect_min_size = Vector2(64,64)
			cell.add_child(spr)
			_GridContainer.add_child(cell)
			grid_dict[Vector2(i,j)] = [cell, spr, id]

func clear_grid():
	for i in range(5):
		for j in range(5):
			grid_dict[Vector2(i,j)][1].texture = load(EmojiIdToFilename.EmojiIdToFilenameDict[10000])
			grid_dict[Vector2(i,j)][2] = 10000

func encode_emojis():
	var encoding = []
	for i in range(5):
		for j in range(5):
			if grid_dict[Vector2(i,j)][2] == 10000:
				continue
			encoding.append([i, j, grid_dict[Vector2(i,j)][2]])
	return encoding

func decode_emojis(encoding):
	clear_grid()
	for i in range(encoding.size()):
		var x = encoding[i][0]
		var y = encoding[i][1]
		var id = encoding[i][2]
		grid_dict[Vector2(x,y)][1].texture = load(EmojiIdToFilename.EmojiIdToFilenameDict[int(id)]) # TODO: Figure out the float/int problem
		grid_dict[Vector2(x,y)][2] = id

func handle_canvas_click(row, column):
	# Check error cases
	if !is_editable:
		return
	if row < 0 or row >= ROWS or column < 0 or column >= COLUMNS:
		return
	if !EmojiIdToFilename.EmojiIdToFilenameDict.has(currently_selected_emoji_id):
		return
	# Handle actual click
	#print("current tool is " + currently_selected_tool)
	match currently_selected_tool:
		"add":
			var path = EmojiIdToFilename.EmojiIdToFilenameDict[currently_selected_emoji_id]
			grid_dict[Vector2(row, column)][1].texture = load(path)
			grid_dict[Vector2(row, column)][2] = currently_selected_emoji_id
		"delete":
			var path = EmojiIdToFilename.EmojiIdToFilenameDict[currently_selected_emoji_id]
			grid_dict[Vector2(row, column)][1].texture = load(EmojiIdToFilename.EmojiIdToFilenameDict[10000])
			grid_dict[Vector2(row, column)][2] = 10000
		"move":
			var id = grid_dict[Vector2(row, column)][2]
			emit_signal("emoji_grabbed", id)
			var path = EmojiIdToFilename.EmojiIdToFilenameDict[10000]
			grid_dict[Vector2(row, column)][1].texture = load(path)
			grid_dict[Vector2(row, column)][2] = 10000
			

func update_emoji_selected(new_emoji_id):
	if !is_editable:
		return
	currently_selected_emoji_id = new_emoji_id

func update_tool_selected(new_tool):
	if !is_editable:
		return
	currently_selected_tool = new_tool