extends Node
const PlayerClass = preload("res://Player.gd")

onready var net = $GameStateManager/Networking

### DEBUG/TESTING ###
func _debug():
	var lobby = $GameStateManager/ScreenManager.currentScreenInstance
	
	var ids = [400025, 2111079, 90001]
	
	randomize()
	
	for x in ids:
		lobby.add_player_id(x)
		lobby.update_player_status2(x, "%d" % x, randi() % 8)
		pass
	for y in range(3, 8):
		lobby.add_player_id(0)
	
	
	var sample1 = PlayerClass.new()
	sample1.playerID = 2005
	sample1.username = "Archie"
	sample1.avatarID = 6
	sample1.isPlayer = 1
	var sample2 = PlayerClass.new()
	sample2.playerID = 1996
	sample2.username = "Lyra"
	sample2.avatarID = 7
	sample2.isPlayer = 1
	var sample3 = PlayerClass.new()
	sample3.playerID = 2017
	sample3.username = "Larry"
	sample3.avatarID = 1
	sample3.isPlayer = 1
	var sample4 = PlayerClass.new()
	sample4.playerID = 2012
	sample4.username = "Alex"
	sample4.avatarID = 0
	sample4.isPlayer = 1
	var sample5 = PlayerClass.new()
	sample5.playerID = 9001
	sample5.username = "Goku"
	sample5.avatarID = 2
	sample5.isPlayer = 1
	
	var players = [sample1, sample2, sample3, sample4, sample5]
	
	lobby.add_player_id(sample1.playerID)
	lobby.update_player_status(sample1)
	
	lobby.update_from_list(players)
	
	lobby.update_audience(8)
	
	return

func _ready():
	
	print("Running LobbyTest...")

	net.emit_signal("obtainedLetterCode", "WARP")
	$GameStateManager/ScreenManager.changeScreenTo(3)
		
	net.emit_signal("playerConnected", 2005, true)
	net.emit_signal("receivedPlayerDetails", 2005, "Oliver", 0)
	net.emit_signal("playerConnected", 2030, true)
	net.emit_signal("receivedPlayerDetails", 2030, "Erin", 1)
	net.emit_signal("playerConnected", 2016, true)
	net.emit_signal("receivedPlayerDetails", 2016, "Squid", 2)
	net.emit_signal("playerConnected", 2413, true)
	net.emit_signal("receivedPlayerDetails", 2413, "Saria", 3)
	net.emit_signal("playerConnected", 2199, true)
	net.emit_signal("receivedPlayerDetails", 2199, "Orion", 4)
	for x in range (101, 201):
		$GameStateManager/Networking.emit_signal("playerConnected", x, false)
	for x in range (101, 201):
		$GameStateManager/Networking.emit_signal("playerDisconnected", x)
		
	$Timer.start()
	

func _on_Timer_timeout():
	net.emit_signal("playerDisconnected", 2016)
	$GameStateManager/ScreenManager.currentScreenInstance.emit_signal("updateGameState", "disconnectLobby")
