extends Node

# # # Signals # # #
signal _connectedToServer
signal _disconnectedFromServer
signal connectedSuccessfully
signal obtainedLetterCode(letterCode)
signal playerConnected(playerID)
signal playerDisconnected(playerID)
signal receivedPlayerDetails(playerID, username, avatarIndex)
signal receivedPlayerAnswer(playerID, promptID, emojiArray)
signal receivedPlayerVote(playerID, promptID, voteID)
signal receivedPlayerMultiVote(playerID, promptID, voteArray)
signal playerBadDisconnect(playerID)
signal playerReconnected(playerID)
signal lostConnection()
# # # # # # # # # #



var defaultServerIP = "18.224.39.240"
#var defaultServerIP = "127.0.0.1"
var defaultServerPort = 3000
var portOffset = 0

var letterCode = "????"
var mostRecentMessage = ""

var socket = null
var startedTest = false

func _ready():
	socket = StreamPeerTCP.new()
	socket.set_no_delay(true)
	#___test()

func ___test():
	if startedTest == true:
		pass

	startedTest = true
	if socket.get_status() == socket.STATUS_NONE:
		connectHostToServer(defaultServerIP, defaultServerPort)


func _process(delta):
	# if connected, check for message
	if socket.get_status() == socket.STATUS_CONNECTED:
		if socket.get_available_bytes() > 0:
			getMessageFromServer()

func connectHostToServer(serverIP, serverPort):
	"""
	Tries to connect the host application to the server
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
			Logger.writeLine("Connecting attempt failed.")
		elif response == OK:
			print("Connection attempt made on " + defaultServerIP + ":" + str(defaultServerPort))
			Logger.writeLine("Connection attempt made on " + defaultServerIP + ":" + str(defaultServerPort))
			emit_signal("_connectedToServer")

func disconnectHostFromServer():
	"""
	Disconnects the Host from the Server
	Arguments:
		none
	Returns:
		none
	"""
	socket.disconnect_from_host()
	print("DisconnectHostFromServer function")
	print(socket.get_status())
	emit_signal("_disconnectedFromServer")

func _on_ConnectingTimer_timeout():
	# Check if host was able to connect to the server
	if socket.get_status() != socket.STATUS_CONNECTED:
		print(socket.get_status())
		print("Connection attempt failed.  Took too long to connect.")
		Logger.writeLine("Connection attempt failed.  Took too long to connect.")
		# Force disconnect
		disconnectHostFromServer()
	else:
		# Successfully connected
		
		print(socket.get_status())
		print("Connection attempt was successful.")
		Logger.writeLine("Connection attempt was successful.")
		print("Now listening on " + defaultServerIP + ":" + str(defaultServerPort))
		Logger.writeLine("Now listening on " + defaultServerIP + ":" + str(defaultServerPort))
		emit_signal("connectedSuccessfully")
		#var msg = {"messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE}
		#sendMessageToServer(msg)

func sendMessageToServer(message):
	# Check if can send message
	if !socket.is_connected_to_host():
		var response = connectPlayerToServer(defaultServerIP, defaultServerPort)
		if response == OK:
			return
		print("Failed to send message.  Not connected to server.")
		Logger.writeLine("Failed to send message (" + str(message) + ").  Not connected to server.")
		emit_signal("lostConnection")
		return
	# Check if valid message
	if message["messageType"] != MESSAGE_TYPES.HOST_REQUESTING_CODE:
		if !message.has("messageType"):
			print("Failed to send message.  Lacking messageType attribute.")
			Logger.writeLine("Failed to send message (" + str(message) + ").  Lacking 'messageType' attribute.")
		if !message.has("letterCode"):
			#print("Failed to send message.  Lacking letterCode attribute.")
			#Logger.writeLine("Failed to send message (" + str(message) + ").  Lacking 'letterCode' attribute.")
			message["letterCode"] = letterCode
	# Send message
	mostRecentMessage = message
	print("Sending message...")
	Logger.writeLine("Sending message...")
	message = $Parser.encodeMessage(message)
	socket.put_utf8_string(message)
	print("Message sent.")
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
			print("Resending message to server.")
			sendMessageToServer(mostRecentMessage)
		MESSAGE_TYPES.SERVER_SENDING_CODE:
			emit_signal("obtainedLetterCode", messageDict["letterCode"])
			print(messageDict["letterCode"])
			letterCode = messageDict["letterCode"]
		MESSAGE_TYPES.SERVER_PING:
			print("PING")
			var msg = {"messageType": MESSAGE_TYPES.HOST_RESPONDING_TO_PING,
				"letterCode": letterCode}
			sendMessageToServer(msg)
		MESSAGE_TYPES.PLAYER_CONNECTED:
			emit_signal("playerConnected", messageDict["playerID"], messageDict["isPlayer"])
		MESSAGE_TYPES.PLAYER_DISCONNECTED:
			emit_signal("playerDisconnected", messageDict["playerID"])
		MESSAGE_TYPES.PLAYER_USERNAME_AND_AVATAR:
			emit_signal("receivedPlayerDetails", messageDict["playerID"], messageDict["username"], messageDict["avatarIndex"])
		MESSAGE_TYPES.PLAYER_SENDING_PROMPT_RESPONSE:
			emit_signal("receivedPlayerAnswer", messageDict["playerID"], messageDict["promptID"], messageDict["emojiArray"])
		MESSAGE_TYPES.PLAYER_SENDING_SINGLE_VOTE:
			emit_signal("receivedPlayerVote", messageDict["playerID"], messageDict["voteID"])
		MESSAGE_TYPES.PLAYER_SENDING_MULTI_VOTE:
			emit_signal("receivedPlayerMultiVote", messageDict["playerID"], messageDict["voteArray"])
		MESSAGE_TYPES.PLAYER_BAD_DISCONNECT:
			emit_signal("playerBadDisconnect", messageDict["playerID"])
		MESSAGE_TYPES.PLAYER_RECONNECT:
			emit_signal("playerReconnected", messageDict["playerID"])
		_:
			print("Unrecognized message code " + str(messageCode))
			Logger.writeLine("Unrecognized message code " + str(messageCode))
