extends Node

var FILE_PATH = "user://saved_connection.dat"
var TEST_ENABLED = false

var player_id
var letter_code

func _ready():
	if TEST_ENABLED:
		__test()


# Stores player and lobby information to a file when a game 
#	session is started in case of a crash
# player_id - the server generated id for a given lobby
# letter_code - the 4 letter code for a given lobby
func save_game_info(player_id, letter_code):
	# Create dict to work with data
	var game_info = {"player_id" : player_id, 
		"letter_code" : letter_code}
	self.player_id = player_id
	self.letter_code = letter_code
	# Create config file to store data
	var cf = ConfigFile.new()
	# Write data to config file
	for key in game_info.keys():
		cf.set_value("DATA", key, game_info[key])
	# Save file
	cf.save(FILE_PATH)


# Loads player and lobby information, if it exists, in order
#	to restore a game session after a crash
# Returns: game_info - dict representing the stored information
#		player_id - the player's server generated id
#		letter_code - the 4 letter code for a given lobby
func load_game_info():
	# Create dict to work with data
	var game_info = {"player_id" : "",
		"letter_code" : ""}
	# Try to open config file
	var cf = ConfigFile.new()
	var error = cf.load(FILE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		pass
	elif error != OK:
		print("Error loading game session file!  Error %s" % error)
		pass
	else:
		# Config file found
		for key in game_info.keys():
			game_info[key] = cf.get_value("DATA", key, "")
		player_id = game_info["player_id"]
		letter_code = game_info["letter_code"]
	# Return initialized dictionary
	return game_info

func get_player_id():
	return player_id

func get_letter_code():
	return letter_code




func __test():
	# Delete config file if it exists already
	var dir = Directory.new()
	dir.remove(FILE_PATH)
	
	var game_info_test = load_game_info()
	assert(game_info_test["player_id"] == "")
	assert(game_info_test["letter_code"] == "")
	
	save_game_info("player01", "")
	var game_info_2_test = load_game_info()
	assert(game_info_2_test["player_id"] == "player01")
	assert(game_info_2_test["letter_code"] == "")
	
	save_game_info("player02", "AAAA")
	var game_info_3_test = load_game_info()
	assert(game_info_3_test["player_id"] == "player02")
	assert(game_info_3_test["letter_code"] == "AAAA")
	
	# Delete config file if it exists already
	var dir2 = Directory.new()
	dir2.remove(FILE_PATH)
	
	save_game_info("player03", "BBBB")
	var game_info_4_test = load_game_info()
	assert(game_info_4_test["player_id"] == "player03")
	assert(game_info_4_test["letter_code"] == "BBBB")