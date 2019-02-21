extends Node

func _ready():
	
	print("Running LobbyTest...")
	$GameStateManager/ScreenManager.changeScreenTo(3)
	$GameStateManager/Networking.emit_signal("playerConnected", 2005, true)
	$GameStateManager/Networking.emit_signal("receivedPlayerDetails", 2005, "Oliver", 0)
	$GameStateManager/Networking.emit_signal("obtainedLetterCode", "WARP")
	

#func _process(delta):
