extends Node

func _ready():
	
	var rf = File.new()
	rf.open("res://Singletons/EmojiFilenameToId.gd", File.READ)
	var wf = File.new()
	wf.open("res://Singletons/EmojiIdToFilename.gd", File.WRITE)
	
	var line = rf.get_line()
	while not rf.eof_reached():
		if not "\"" in line:
			line = rf.get_line()
			continue
		line = line.replace(",", "")
		var tokens = line.split(" ")
		var new_string = tokens[2] + " : " + tokens[0] + ","
		wf.store_line(new_string)
		
		line = rf.get_line()
	rf.close()
	wf.close()

func convert_to_string():
	
	var rf = File.new()
	rf.open("res://Singletons/EmojiIdToFilename.gd", File.READ)
	var wf = File.new()
	wf.open("res://Singletons/EmojiIdToFilename2.gd", File.WRITE)
	
	var line = rf.get_line()
	while not rf.eof_reached():
		if not "\"" in line:
			wf.store_line(line)
			line = rf.get_line()
			continue
		line = line.replace(",", "")
		var tokens = line.split(" ")
		var new_string = "\"" + tokens[0] + "\" : " + tokens[2] + ","
		wf.store_line(new_string)
		
		line = rf.get_line()
	rf.close()
	wf.close()