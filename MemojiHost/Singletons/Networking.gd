extends Node

# # # Signals # # #
signal _connectedToServer
signal _disconnectedFromServer
signal obtainedLetterCode(letterCode)
signal playerConnected(playerID)
signal playerDisconnected(playerID)
signal receivedPlayerDetails(playerID, username, avatarIndex)
signal receivedPlayerAnswer(playerID, promptID, emojiArray)
signal receivedPlayerVote(playerID, promptID, voteID)
signal receivedPlayerMultiVote(playerID, promptID, voteArray)
# # # # # # # # # #



var defaultServerIP = "127.0.0.1"
var defaultServerPort = 7575

var letterCode = "????"

var socket = null
var startedTest = false

func _ready():
	socket = StreamPeerTCP.new()
	___test()

func ___test():
	if startedTest == true:
		pass

	startedTest = true
	if socket.get_status() == socket.STATUS_NONE:
		connectHostToServer(defaultServerIP, defaultServerPort)
	testMatch()


func _process(delta):
	# if connected, check for message
	if socket.get_status() == socket.STATUS_CONNECTED:
		#pass
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
	if !socket.is_connected_to_host():
		$ConnectingTimer.start()
		var response = socket.connect_to_host(serverIP, serverPort)
		print(socket.get_status())
		if response == FAILED:
			print("Connection attempt failed.")
		elif response == OK:
			print("Connection attempt made on " + defaultServerIP + ":" + str(defaultServerPort))
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
	emit_signal("_disconnectedFromServer")

func _on_ConnectingTimer_timeout():
	# Check if host was able to connect to the server
	if socket.get_status() != socket.STATUS_CONNECTED:
		print(socket.get_status())
		print("Connection attempt failed.  Took too long to connect.")
		# Force disconnect
		disconnectHostFromServer()
	else:
		# Successfully connected
		print(socket.get_status())
		print("Connection attempt was successful.")
		print("Now listening on " + defaultServerIP + ":" + str(defaultServerPort))
		# TODO REMOVE THIS TODO #
		var msg = {"messageType": MESSAGE_TYPES.HOST_REQUESTING_CODE}
		sendMessageToServer(msg)
		# # # # # # # # # # # # #

func sendMessageToServer(message):
	# Check if can send message
	if !socket.is_connected_to_host():
		print("Failed to send message.  Not connected to server.")
		return
	# Check if valid message
	if !message.has("messageType"):
		print("Failed to send message.  Lacking messageType attribute.")
	if !message.has("letterCode"):
		print("Failed to send message.  Lacking letterCode attribute.")
	# Send message
	print("Sending message...")
	message = $Parser.encodeMessage(message)
	socket.put_utf8_string(message)
	print("Message sent.")

func getMessageFromServer():
	# Check if can get message
	if !socket.is_connected_to_host():
		print("Failed to get message.  Not connected to server.")
		return
	# Obtain message
	var messageLen = $Parser.getMessageLength(socket)
	print(messageLen)
	var messageJson = ""
	for i in range(messageLen):
		messageJson += socket.get_utf8_string(1)
	print(messageJson)

	# Convert message to dictionary
	var messageDict = $Parser.decodeMessage(messageJson)
	# Decode message purpose and send appropriate signal
	var messageCode = messageDict["messageType"]
	print(messageCode)
	match int(messageCode):
		MESSAGE_TYPES.SERVER_SENDING_CODE:
			emit_signal("obtainedLetterCode", messageDict["letterCode"])
			print(messageDict["letterCode"])
			letterCode = messageDict["letterCode"]
		MESSAGE_TYPES.SERVER_PING:
			var msg = {"messageType": MESSAGE_TYPES.HOST_RESPONDING_TO_PING}
			sendMessageToServer($Parser.encodeMessage(msg))
		MESSAGE_TYPES.PLAYER_CONNECTED:
			emit_signal("playerConnected", messageDict["playerId"])
		MESSAGE_TYPES.PLAYER_DISCONNECTED:
			emit_signal("playerDisconnected", messageDict["playerId"])
		MESSAGE_TYPES.PLAYER_USERNAME_AND_AVATAR:
			emit_signal("receivedPlayerDetails", messageDict["playerId"], messageDict["username"], messageDict["avatarIndex"])
		MESSAGE_TYPES.PLAYER_SENDING_PROMPT_RESPONSE:
			emit_signal("receivedPlayerAnswer", messageDict["playerId"], messageDict["promptId"], messageDict["emojiArray"])
		MESSAGE_TYPES.PLAYER_SENDING_SINGLE_VOTE:
			emit_signal("receivedPlayerVote", messageDict["playerId"], messageDict["promptId"], messageDict["voteID"])
		MESSAGE_TYPES.PLAYER_SENDING_MULTI_VOTE:
			emit_signal("receivedPlayerMultiVote", messageDict["playerId"], messageDict["promptId"], messageDict["voteArray"])
		_:
			print("Unrecognized message code " + str(messageCode))