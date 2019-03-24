extends GridContainer

export(Array, String) var emoji_directories = [""]
export(int) var emoji_id = -1

signal emoji_button_pressed(id)

var CREATING_ID_FILES = true
var BUTTON_SIZE = 50

var screen_width = 0

var EmojiButton = preload("res://Screens/Elements/EmojiCanvasSubElements/EmojiButton.tscn")
var EmojiButtonGroup = preload("res://Screens/Elements/EmojiCanvasSubElements/EmojiPaletteButtonGroup.tres")

func _ready():
	get_tree().get_root().connect("size_changed", self, "update_columns")
	
	for dir_path in emoji_directories:
		# Create files of ids
		var f = File.new()
		var save_filename = dir_path + "/savefile.txt"
		if CREATING_ID_FILES:
			f.open(save_filename, File.WRITE)
		
		# Add buttons
		#var dir_path = "res://Assets/Emojis/faces_people_clothes/plain/emojis"
		var dir = Directory.new()
		if dir.open(dir_path) != OK:
			print("An error occurred when trying to access path " + dir_path)
			Logger.writeLine("An error occurred when trying to access path " + dir_path)
			continue
		# initialize iterator
		dir.list_dir_begin()
		# get first file
		var file_name = dir.get_next()
		while(file_name != ""):
			# ignore .import files
			if ".import" in file_name:
				file_name = dir.get_next()
				continue
			# ignore non-png files
			elif ".png" in file_name:
				#print("Found file: " + file_name)
				var icon_texture = load(dir_path + "/" + file_name)
				var b = EmojiButton.instance()
				var icon = Sprite.new()
				icon.texture = icon_texture
				icon.set_scale(Vector2(0.5,0.5))
				icon.centered = false
				icon.offset = Vector2(8,8)
				b.add_child(icon)
				#b.set_emoji_id(emoji_id)
				b.set_emoji_id(EmojiFilenameToId.EmojiFilenameToIdDict[dir_path + "/" + file_name])
				#b.rect_min_size = Vector2(44,44)
				b.group = EmojiButtonGroup
				#b.toggle_mode = true
				b.connect("emoji_button_pressed", self, "_child_emoji_button_pressed")
				add_child(b)
				
				if CREATING_ID_FILES:
					f.store_line("\"" + dir_path + "/" + file_name + "\" : " + str(emoji_id) + ",")
				emoji_id += 10
				
			# get next file
			file_name = dir.get_next()
		
		if CREATING_ID_FILES:
			f.close()
	
	# Setup grid layout
	update_columns()

func _child_emoji_button_pressed(id):
	emit_signal("emoji_button_pressed", id)
	#print("signal of id " + str(id) + " received in Palette")

func update_columns():
	columns = rect_size.x / BUTTON_SIZE
	print(str(columns) + " " + str(rect_size.x) + " " + str(BUTTON_SIZE))
	if columns < 1:
		columns = 1