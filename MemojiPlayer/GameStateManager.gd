extends Node

var playerScene = preload("res://Player.tscn")

enum GAME_STATE {
	NOT_STARTED = 0
	GAME_STARTING = -1
	PROMPT_PHASE = 1
	VOTE_PHASE = 2
	RESULTS_PHASE = 3
	ROUND_RESULTS = 4
	FINAL_RESULTS = 5
	MULTI_PROMPT_PHASE = 6
	MULTI_VOTE_PHASE = 7
	MULTI_RESULTS_PHASE = 8
	CREDITS = 9
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
	$ScreenManager.connect("updateLetterCode", self, "updateLetterCode")
	$Networking.connect("_disconnectedFromServer", self, "_on_Networking_connectionTimeout")

func handleReceivedPrompt(prompt_id, prompt_text):
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

func handleReceivedAnswers(prompt, answers):
	if answers.size() == 2:
		if $ScreenManager.currentScreen == $ScreenManager.SCREENS.WAITING_SCREEN:
			$ScreenManager.changeScreenTo($ScreenManager.SCREENS.PLAYER_VOTING_SCREEN)
			if $ScreenManager.currentScreen == $ScreenManager.SCREENS.PLAYER_VOTING_SCREEN:
				$ScreenManager.currentScreenInstance.set_answers(answers, prompt)
	else:
		# Change to final voting screen
		if $ScreenManager.currentScreen == $ScreenManager.SCREENS.WAITING_SCREEN:
			$ScreenManager.changeScreenTo($ScreenManager.SCREENS.FINAL_VOTING_SCREEN)
			if $ScreenManager.currentScreen == $ScreenManager.SCREENS.FINAL_VOTING_SCREEN:
				$ScreenManager.currentScreenInstance.set_answers(answers)
				$ScreenManager.currentScreenInstance.set_prompt_text(prompt)

func updateLetterCode(letter_code):
	$Networking.letterCode = letter_code
	lobbyCode = letter_code

func _on_ScreenManager_sendMessageToServer(msg):
	if player != null:
		msg["playerID"] = player.playerID
	else:
		msg["playerID"] = SessionStorer.get_player_id()
	$Networking.sendMessageToServer(msg)

func _on_ScreenManager_updateGameState(newState):
	currentState = newState

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		get_tree().quit()


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

func _on_Networking_acceptedPlayerReconnection():
	print("Player reconnected to server properly")


func _on_Networking_updatePlayerGameState(messageDict):
	print("GameState from message: " + str(messageDict["gameState"]))
	match (int(messageDict["gameState"])):
		GAME_STATE.NOT_STARTED:
			$ScreenManager.changeScreenTo($ScreenManager.SCREENS.USERINFORMATION_SCREEN)
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
		GAME_STATE.MULTI_PROMPT_PHASE:
			$ScreenManager.changeScreenTo($ScreenManager.SCREENS.WAITING_SCREEN)
			for x in range(messageDict["promptIDs"].size()):
				handleReceivedPrompt(messageDict["promptIDs"][x], messageDict["promptText"][x])
		GAME_STATE.MULTI_VOTE_PHASE:
			$ScreenManager.changeScreenTO($ScreenManager.SCREENS.WAITING_SCREEN)
			handleReceivedAnswers(messageDict["prompt"], messageDict["answers"])
			pass
		_:
			$ScreenManager.changeScreenTo($ScreenManager.SCREENS.WAITING_SCREEN)
	currentState = messageDict["gameState"]
	print("End of updatePlayerGameState")

func _on_Networking_hostTimeOut():
	print("[DEBUG]: Host Timer time out!")
	# Find what current state is
	match (currentState):
		GAME_STATE.PROMPT_PHASE:
			# Force send prompts
			# Simulate sending player prompt
			if $ScreenManager.currentScreen == $ScreenManager.SCREENS.PROMPT_ANSWERING_SCREEN:
				var num_prompts = $ScreenManager.currentScreenInstance.get_num_prompts() + 1
				print("[DEBUG]: num_prompts: " + str(num_prompts))
				for x in range(num_prompts):
					$ScreenManager.currentScreenInstance._on_SubmitButton_pressed()
		GAME_STATE.VOTE_PHASE:
			# Force change screen
			if $ScreenManager.currentScreen == $ScreenManager.SCREENS.PLAYER_VOTING_SCREEN:
				$ScreenManager.changeScreenTo($ScreenManager.SCREENS.WAITING_SCREEN)


################################
# # # # # TITLE SCREEN # # # # #
################################
func _on_Networking_enteredValidHostCode(playerID, isPlayer, code):
	lobbyCode = code
	player = playerScene.instance()
	player.playerID = playerID
	player.isPlayer = isPlayer
	if $ScreenManager.currentScreen == $ScreenManager.SCREENS.TITLE_SCREEN:
		if !isPlayer:
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

func _on_Networking_hostNewGame():
	$ScreenManager.changeScreenTo($ScreenManager.SCREENS.LOBBY_SCREEN)


##########################################
# # # # # PLAYER RESPONSE SCREEN # # # # #
##########################################
func _on_Networking_promptReceived(prompt_id, prompt_text):
	handleReceivedPrompt(prompt_id, prompt_text)

func _on_Networking_enteredValidAnswer():
	pass # replace with function body

func _on_Networking_enteredInvalidAnswer():
	pass # replace with function body


#################################
# # # # # VOTING SCREEN # # # # #
#################################
func _on_Networking_answersReceived(prompt, answers):
	handleReceivedAnswers(prompt, answers)

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
