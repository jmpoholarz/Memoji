extends Node

var playerScene = preload("res://Player.tscn")

enum GAME_STATE {
	NOT_STARTED = 0
	PROMPT_PHASE = 1
	VOTE_PHASE = 2
	RESULTS_PHASE = 3
	ROUND_RESULTS = 4
	FINAL_RESULTS = 5
}

var currentRound
var currentState
var player
var playerName = ""
var playerIcon = -1
var lobbyCode = "????"
var current_prompts = []



func _ready():
	$ScreenManager.changeScreenTo($ScreenManager.TITLE_SCREEN)

	$ScreenManager.connect("connectToServer", self, "connectToServer")
	$ScreenManager.connect("disconnectFromServer", self, "disconnectFromServer")
	$Networking.connect("_disconnectedFromServer", self, "_on_Networking_connectionTimeout")


func _on_ScreenManager_sendMessageToServer(msg):
	if player != null:
		msg["playerID"] = player.playerID
	$Networking.sendMessageToServer(msg)

func _on_ScreenManager_updateGameState(newState):
	currentState = newState


######################################
# # # # # GENERAL NETWORKING # # # # #
######################################
func connectToServer():
	#Sprint("in GSM connectToServer")
	$Networking.connectPlayerToServer($Networking.defaultServerIP, $Networking.defaultServerPort)

func disconnectFromServer():
	$Networking.disconnectPlayerFromServer()
	# Store empty game session
	SessionStorer.save_game_info("", "")

func _on_Networking_lostConnection():
	# Tried to send message but client is not connected to server
	# Popup that internet connection is borked
	$ScreenManager.lost_connection()

func _on_Networking_gameEndedByHost():
	$ScreenManager.changeScreenTo($ScreenManager.SCREENS.LOBBY_SCREEN)
	lobbyCode = "????"
	# Store game session
	SessionStorer.save_game_info("", "")

func _on_Networking_forcedToDisconnect():
	$Networking.disconnectPlayerFromServer()
	$ScreenManager.changeScreenTo($ScreenManager.SCREENS.TITLE_SCREEN)
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Player Disconnected from Host")
	lobbyCode = "????"
	# Store empty game session
	SessionStorer.save_game_info("", "")

func _on_Networking_updatePlayerGameState(messageDict):
	match (messageDict["gameState"]):
		GAME_STATE.NOT_STARTED:
			currentState = messageDict["gameState"]
		GAME_STATE.PROMPT_PHASE:
			# We have prompts to answer
			# Look at received prompts
			$ScreenManager.changeScreenTo($ScreenManager.SCREENS.WAITING_SCREEN)
			for x in range(messageDict["promptIDs"].size()):
				handleReceivedPrompt(messageDict["promptIDs"][x], messageDict["promptText"][x])
		GAME_STATE.VOTE_PHASE:
			# We have voting to do
			$ScreenManager.changeScreenTo($ScreenManager.SCREENS.WAITING_SCREEN)
			handleReceivedAnswers(messageDict["prompt"], messageDict["answers"])
			pass
		GAME_STATE.RESULTS_PHASE:
			# TODO
			pass
		GAME_STATE.ROUND_RESULTS:
			# TODO
			pass
		GAME_STATE.FINAL_RESULTS:
			# TODO
			pass
	pass # replace with function body


################################
# # # # # TITLE SCREEN # # # # #
################################
func _on_Networking_enteredValidHostCode(playerID, isPlayer, code):
	lobbyCode = code
	player = playerScene.instance() #might not work
	player.playerID = playerID
	player.isPlayer = isPlayer
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		if isPlayer:
			$ScreenManager.changeScreenTo($ScreenManager.LOBBY_SCREEN)
			playerName = "Audience"
			$ScreenManager.currentScreenInstance.hide_back_button()
		else:
			$ScreenManager.changeScreenTo($ScreenManager.USERINFORMATION_SCREEN)
		SessionStorer.save_game_info(player.playerID, $Networking.letterCode)

func _on_Networking_enteredInvalidHostCode():
	#if $ScreenManager.currentScene == $ScreenManager.SCREENS.TITLE_SCREEN:
	#	$ScreenManager/TitleScreen._on_InvalidRoomCode()
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Entered code does not exist.  Check spelling and retry.")

func _on_Networking_connectionTimeout():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		print("on_Networking_connectionTimeout")
		$ScreenManager.currentScreenInstance.show_ServerErrorPopup("Could not connect to server.  Connection Timeout.")


#############################################
# # # # # PLAYER INFORMATION SCREEN # # # # #
#############################################
func _on_Networking_enteredValidUsername(pName, pIcon):
	playerName = pName
	playerIcon = pIcon
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.SCREENS.LOBBY_SCREEN)
		$ScreenManager.currentScreenInstance.new_room_code(lobbyCode)

func _on_Networking_enteredInvalidUsername():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.USERINFORMATION_SCREEN:
		$ScreenManager/currentScreenInstance._on_InvalidName()
	pass # replace with function body


################################
# # # # # LOBBY SCREEN # # # # #
################################
func _on_Networking_gameStartedByHost():
	# Advance players to waiting for prompt screen
	$ScreenManager.changeScreenTo($ScreenManager.SCREENS.WAITING_SCREEN)
	# Store game session
	#SessionStorer.save_game_info(player.playerID, $Networking.letterCode)


##########################################
# # # # # PLAYER RESPONSE SCREEN # # # # #
##########################################
func _on_Networking_promptReceived(prompt_id, prompt_text):
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.WAITING_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.SCREENS.PROMPT_ANSWERING_SCREEN)
		if $ScreenManager.currentScreen != $ScreenManager.SCREENS.PROMPT_ANSWERING_SCREEN:
			yield($ScreenManager, "screen_change_completed") # Needs testing
		current_prompts.append([prompt_id, prompt_text])
		$ScreenManager.currentScreenInstance.add_prompts([[prompt_id, prompt_text]])
		$ScreenManager.currentScreenInstance.get_next_prompt()
	elif $ScreenManager.currentScreen == $ScreenManager.SCREENS.PROMPT_ANSWERING_SCREEN:
		current_prompts.append([prompt_id, prompt_text])
		$ScreenManager.currentScreenInstance.add_prompts([[prompt_id, prompt_text]])

func _on_Networking_enteredValidAnswer():
	pass # replace with function body

func _on_Networking_enteredInvalidAnswer():
	pass # replace with function body


#################################
# # # # # VOTING SCREEN # # # # #
#################################
func _on_Networking_answersReceived(prompt, answers):
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.WAITING_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.PLAYER_VOTING_SCREEN)
		if $ScreenManager.currentScreen == $ScreenManager.SCREENS.PLAYER_VOTING_SCREEN:
			$ScreenManager.currentScreenInstance.set_answers(answers)

func _on_Networking_enteredValidVote():
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.PLAYER_VOTING_SCREEN:
		$ScreenManager.changeScreenTo($ScreenManager.SCREENS.PLAYER_WAITING_AFTER_VOTING_SCREEN)
	pass # replace with function body

func _on_Networking_enteredInvalidVote():
	pass # replace with function body

func _on_Networking_enteredValidMultiVote():
	pass # replace with function body

func _on_Networking_enteredInvalidMultiVote():
	pass # replace with function body
