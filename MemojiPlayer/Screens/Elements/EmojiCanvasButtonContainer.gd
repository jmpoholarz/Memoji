extends GridContainer

var CREATING_ID_FILES = false
var BUTTON_SIZE = 50
export(Array, String) var emoji_directories = [""]
export(int) var emoji_id = -1

var screen_width = 0

var EmojiButton = preload("res://Screens/Elements/EmojiButton.tscn")

func _ready():
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
				b.set_emoji_id(emoji_id)
				#b.rect_min_size = Vector2(44,44)
				
				#b.icon = icon_texture
				#b.icon.set_scale(Vector2(0.5, 0.5))
				add_child(b)
				
				if CREATING_ID_FILES:
					f.store_line("\"" + dir_path + "/" + file_name + "\" : " + str(emoji_id) + ",")
				emoji_id += 10
				
			# get next file
			file_name = dir.get_next()
	
	# Setup grid layout
	columns = rect_size.x / BUTTON_SIZE
	if columns < 1:
		columns = 1

