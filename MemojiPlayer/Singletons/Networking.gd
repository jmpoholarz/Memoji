extends Node

# # # Signals # # #
signal _connectedToServer
signal _disconnectedFromServer
signal enteredValidHostCode(playerID, isPlayer)
signal enteredInvalidHostCode
signal forcedToDisconnect
signal gameStartedByHost
signal gameEndedByHost
signal promptReceived(promptID, prompt)
signal answersReceived(prompt, answerArray)
signal enteredInvalidUsername
signal enteredValidUsername
signal enteredInvalidAnswer
signal enteredValidAnswer
signal enteredInvalidVote
signal enteredValidVote
signal enteredInvalidMultiVote
signal enteredValidMultiVote
signal acceptedPlayerReconnection()
signal updatePlayerGameState(messageDict)
signal lostConnection()
# # # # # # # # # #

var defaultServerIP = "18.224.39.240"
#var defaultServerIP = "127.0.0.1"
#var defaultServerPort = 7575
var defaultServerPort = 3000

var letterCode = "????"
var mostRecentMessage = ""

var socket = null
var startedTest = false

func _ready():
	socket = StreamPeerTCP.new()
	socket.set_no_delay(true)

	#___test()

func ___test():
	#if startedTest == true:
	#	pass

	#startedTest = true
	#if socket.get_status() == socket.STATUS_NONE:
	#	connectPlayerToServer(defaultServerIP, defaultServerPort)
	pass


func _process(delta):
	# if connected, check for message
	if socket.get_status() == socket.STATUS_CONNECTED:
		#pass
		if socket.get_available_bytes() > 0:
			getMessageFromServer()


func connectPlayerToServer(serverIP, serverPort):
	"""
	Tries to connect the player application to the server
	Arguments:
		serverIP - the string IP address of the server being connected to
		serverPort - the integer port number of the server being connected to
	Returns:
		none
	"""
	if !(socket.get_status() == socket.STATUS_NONE):
		return
	if !socket.is_connected_to_host():
		$ConnectingTimer.start()
		var response = socket.connect_to_host(serverIP, serverPort)
		print(socket.get_status())
		if response == FAILED:
			print("Connection attempt failed.")
			Logger.writeLine("Connection attempt failed.")
		elif response == OK:
			print("Connection attempt made on " + defaultServerIP + ":" + str(defaultServerPort))
			Logger.writeLine("Connection attempt made on " + defaultServerIP + ":" + str(defaultServerPort))
			emit_signal("_connectedToServer")
		return response

func disconnectPlayerFromServer():
	"""
	Disconnects the Player from the Server
	Arguments:
		none
	Returns:
		none
	"""
	socket.disconnect_from_host()
	print("disconnectPlayerFromServer runs")


func _on_ConnectingTimer_timeout():
	if socket.get_status() != socket.STATUS_CONNECTED:
		print(socket.get_status())
		print("Connection attempt failed.  Took too long to connect.")
		Logger.writeLine("Connection attempt failed.  Took too long to connect.")
		# Force disconnect
		disconnectPlayerFromServer()
		emit_signal("_disconnectedFromServer")
	else:
		print(socket.get_status())
		print("Connection attempt was successful.")
		Logger.writeLine("Connection attempt was successful.")
		print("Now listening on " + defaultServerIP + ":" + str(defaultServerPort))
		Logger.writeLine("Now listening on " + defaultServerIP + ":" + str(defaultServerPort))

func sendMessageToServer(message):
	# Check if can send message
	if !socket.is_connected_to_host():
		var response = connectPlayerToServer(defaultServerIP, defaultServerPort)
		yield(get_tree().create_timer(1), "timeout")
		if response == OK:
			# Send reconnection message to server
			var reconn_message = {
				"messageType": 406,
				"letterCode": SessionStorer.get_letter_code(),
				"playerID": SessionStorer.get_player_id()
			}
			sendMessageToServer(reconn_message)
			return
		print("Failed to send message.  Not connected to server.")
		emit_signal("lostConnection")
		Logger.writeLine("Failed to send message (" + str(message) + ").  Not connected to server.")
		return
	# Check if valid message
	if message["messageType"] != MESSAGE_TYPES.HOST_REQUESTING_CODE:
		#print("Failed to send message.  Lacking messageType attribute.")
		Logger.writeLine("Failed to send message (" + str(message) + ").  Lacking 'messageType' attribute.")
	if !message.has("letterCode"):
		#print("Failed to send message.  Lacking letterCode attribute.")
		#Logger.writeLine("Failed to send message (" + str(message) + ").  Lacking 'letterCode' attribute.")
		message["letterCode"] = letterCode
	# Send message
	mostRecentMessage = message
	print("Sending player message...")
	Logger.writeLine("Sending player message...")
	message = $Parser.encodeMessage(message)
	socket.put_utf8_string(message)
	print("Player message (" + str(message) + ") sent.")
	Logger.writeLine("Message (" + str(message) + ") sent.")

func getMessageFromServer():
	# Check if can get message
	if !socket.is_connected_to_host():
		print("Failed to get message.  Not connected to server.")
		Logger.writeLine("Failed to get message.  Not connected to server.")
		return
	# Send acknowledgment to try to fix the ' bug
	socket.put_u8(3);
	# Obtain message
	var messageLen = $Parser.getMessageLength(socket)
	print(messageLen)
	var messageJson = ""
	for i in range(messageLen):
		messageJson += socket.get_utf8_string(1)
	print(messageJson)
	Logger.writeLine("Obtained message of length " + str(messageLen) + " with text (" + str(messageJson) + ").")

	# Handle error reading message
	if messageLen <= 0:
		return

	# Convert message to dictionary
	var messageDict = $Parser.decodeMessage(messageJson)
	# Decode message purpose and send appropriate signal
	var messageCode = messageDict["messageType"]
	print(messageCode)
	match int(messageCode):
		MESSAGE_TYPES.SERVER_MESSAGE_ERROR:
			sendMessageToServer(mostRecentMessage)
		MESSAGE_TYPES.VALID_SERVER_CODE:
			letterCode = messageDict["letterCode"]
			emit_signal("enteredValidHostCode", messageDict["playerID"], messageDict["isPlayer"], messageDict["letterCode"])
		MESSAGE_TYPES.INVALID_SERVER_CODE:
			emit_signal("enteredInvalidHostCode")
		MESSAGE_TYPES.ACCEPTED_PLAYER_RECONNECTION:
			emit_signal("acceptedPlayerReconnection")
		MESSAGE_TYPES.SERVER_FORCE_DISCONNECT_CLIENT:
			print("Forcibly disconnected from Host by Server.")
			emit_signal("forcedToDisconnect")
			disconnectPlayerFromServer()
		MESSAGE_TYPES.HOST_STARTING_GAME:
			emit_signal("gameStartedByHost")
		MESSAGE_TYPES.HOST_ENDING_GAME:
			emit_signal("gameEndedByHost")
		MESSAGE_TYPES.HOST_SENDING_PROMPT:
			emit_signal("promptReceived", messageDict["promptID"], messageDict["prompt"])
		MESSAGE_TYPES.HOST_SENDING_ANSWERS:
			emit_signal("answersReceived", messageDict["prompt"], messageDict["answers"])
		MESSAGE_TYPES.INVALID_USERNAME:
			emit_signal("enteredInvalidUsername")
		MESSAGE_TYPES.ACCEPTED_USERNAME_AND_AVATAR:
			emit_signal("enteredValidUsername", messageDict["username"], messageDict["avatarIndex"])
		MESSAGE_TYPES.INVALID_PROMPT_RESPONSE:
			emit_signal("enteredInvalidAnswer")
		MESSAGE_TYPES.ACCEPTED_PROMPT_RESPONSE:
			emit_signal("enteredValidAnswer")
		MESSAGE_TYPES.INVALID_VOTE_RESPONSE:
			emit_signal("enteredInvalidVote")
		MESSAGE_TYPES.ACCEPTED_VOTE_RESPONSE:
			emit_signal("enteredValidVote")
		MESSAGE_TYPES.INVALID_MULTI_VOTE:
			emit_signal("enteredInvalidMultiVote")
		MESSAGE_TYPES.ACCEPTED_MULTI_VOTE:
			emit_signal("enteredInvalidMultiVote")
		MESSAGE_TYPES.UPDATE_PLAYER_GAME_STATE:
			print("UPDATE_PLAYER_GAME_STATE")
			emit_signal("updatePlayerGameState", messageDict)
		_:
			print("Unrecognized message code " + str(messageCode))
			Logger.writeLine("Unrecognized message code " + str(messageCode))
