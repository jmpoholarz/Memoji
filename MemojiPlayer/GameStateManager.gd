extends Node

var playerScene = preload("res://Player.tscn") 

var currentRound
var currentState
var player
var lobbyCode
var playerName = "name"
var playerIcon = 0

var current_prompts = []

func _ready():
	$ScreenManager.changeScreenTo($ScreenManager.TITLE_SCREEN)
	
	$ScreenManager.connect("connectToServer", self, "connectToServer")
	$ScreenManager.connect("disconnectFromServer", self, "disconnectFromServer")
	$Networking.connect("_disconnectedFromServer", self, "_on_Networking_connectionTimeout")

func sendAnswer():
	pass

func sendAnswersForVoting():
	pass

func connectToServer():
	#Sprint("in GSM connectToServer")
	$Networking.connectPlayerToServer($Networking.defaultServerIP, $Networking.defaultServerPort)

func disconnectFromServer():
	$Networking.disconnectPlayerFromServer()

func _on_Networking_connectionTimeout():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		print("on_Networking_connectionTimeout")
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Could not connect to server.  Connection Timeout.")


func _on_Networking_answersReceived(answers):
	$ScreenManager.changeScreenTo($ScreenManager.PLAYER_VOTING_SCREEN)
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.PLAYER_VOTING_SCREEN:
		#$ScreenManager/currentScreenInstance.receive_answerArray(answerArray)
		$ScreenManager.currentScreen.set_answers(answers)
	pass # replace with function body
	#Manoj

func _on_Networking_enteredInvalidAnswer():
#	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		
	pass # replace with function body

func _on_Networking_enteredValidHostCode(playerID, isPlayer, code):
	lobbyCode = code
	player = playerScene.instance() #might not work
	player.playerID = playerID
	player.isPlayer = isPlayer
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.USERINFORMATION_SCREEN)

func _on_Networking_enteredInvalidHostCode():
	#if $ScreenManager.currentScene == $ScreenManager.SCREENS.TITLE_SCREEN:
	#	$ScreenManager/TitleScreen._on_InvalidRoomCode()
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Entered code does not exist.  Check spelling and retry.")

func _on_Networking_enteredInvalidUsername():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager/currentScreenInstance._on_InvalidName()
	pass # replace with function body

func _on_Networking_promptReceived(promptID, prompt):
	#print("GSM promptReceived(prompt)")
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.WAITING_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.SCREENS.PROMPT_ANSWERING_SCREEN)
		# Wait for the screen to change to the Prompt Screen before continuing
		#print("about to yeild to screen change")
		if $ScreenManager.currentScreen != $ScreenManager.SCREENS.PROMPT_ANSWERING_SCREEN:
			yield($ScreenManager, "screen_change_completed") # Needs testing
		#print("yield has completed")
		current_prompts.append([promptID, prompt])
		$ScreenManager.currentScreenInstance.add_prompts([prompt])
		#print("prompt added to currentScreen")
		$ScreenManager.currentScreenInstance.get_next_prompt()
		#print("next prompt got")
	elif $ScreenManager.currentScreen == $ScreenManager.SCREENS.PROMPT_ANSWERING_SCREEN:
		#print("GSM prompt received on PROMPT_ANSWERING_SCREEN")
		current_prompts.append([promptID, prompt])
		$ScreenManager.currentScreenInstance.add_prompts([[promptID, prompt]])


func _on_Networking_enteredValidAnswer():
	pass # replace with function body

func _on_Networking_enteredValidMultiVote():
	pass # replace with function body


func _on_Networking_enteredValidUsername(pName, pIcon):
	playerName = pName
	playerIcon = pIcon
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.SCREENS.LOBBY_SCREEN)
		$ScreenManager.currentScreenInstance.new_room_code(lobbyCode)

func _on_Networking_enteredInvalidMultiVote():
	pass # replace with function body

func _on_Networking_enteredValidVote():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.PLAYER_VOTING_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.SCREENS.PLAYER_WAITING_AFTER_VOTING_SCREEN)
	pass # replace with function body

func _on_Networking_enteredInvalidVote():
	pass # replace with function body

func _on_Networking_forcedToDisconnect():
	print("in GSM force disconnect")
	$Networking.disconnectPlayerFromServer()
	$ScreenManager.changeScreenTo($ScreenManager.SCREENS.TITLE_SCREEN)
	lobbyCode = "????"

func _on_Networking_gameEndedByHost():
	$Networking.disconnectPlayerFromServer()
	$ScreenManager.changeScreenTo($ScreenManager.SCREENS.TITLE_SCREEN)
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Player Disconnected from Host")
	
	lobbyCode = "????"
	pass # replace with function body

func _on_Networking_gameStartedByHost():
	# Advance players to waiting for prompt screen
	$ScreenManager.changeScreenTo($ScreenManager.SCREENS.WAITING_SCREEN)



func _on_ScreenManager_sendMessageToServer(msg):
	print("in GSM with message " + str(msg))
	if player != null:
		msg["playerID"] = player.playerID
	$Networking.sendMessageToServer(msg)


