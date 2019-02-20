extends Node

func _ready():
	print("Running LobbyTest...")
	$GameStateManager/Networking.emit_signal("playerConnected", 2005, true)
	$GameStateManager/Networking.emit_signal("receivedPlayerDetails", 2005, "Oliver", 0)

	

#func _process(delta):
