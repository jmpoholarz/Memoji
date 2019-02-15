extends Node

# # # Signals # # #
signal _connectedToServer
signal _disconnectedFromServer
signal enteredValidHostCode
signal enteredInvalidHostCode
signal forcedToDisconnect
signal gameStartedByHost
signal gameEndedByHost
signal promptsReceived(promptArray)
signal answersReceived(answerArray)
signal enteredInvalidUsername
signal enteredValidUsername
signal enteredInvalidAnswer
signal enteredValidAnswer
signal enteredInvalidVote
signal enteredValidVote
signal enteredInvalidMultiVote
signal enteredValidMultiVote
# # # # # # # # # #

var defaultServerIP = "127.0.0.1"
var defaultServerPort = 7575

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
	if !socket.is_connected_to_host():
		$ConnectingTimer.start()
		var response = socket.connect_to_host(serverIP, serverPort)
		print(socket.get_status())
		if response == FAILED:
			print("Connection attempt failed.")
		elif response == OK:
			print("Connection attempt made on " + defaultServerIP + ":" + str(defaultServerPort))
			emit_signal("_connectedToServer")

func disconnectPlayerFromServer():
	"""
	Disconnects the Player from the Server
	Arguments:
		none
	Returns:
		none
	"""
	socket.disconnect_from_host()
	emit_signal("_disconnectedFromServer")

func _on_ConnectingTimer_timeout():
	if socket.get_status() != socket.STATUS_CONNECTED:
		print(socket.get_status())
		print("Connection attempt failed.  Took too long to connect.")
		# Force disconnect
		disconnectPlayerFromServer()
	else:
		print(socket.get_status())
		print("Connection attempt was successful.")
		print("Now listening on " + defaultServerIP + ":" + str(defaultServerPort))
		sendMessageToServer("Test Message from Player")

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
	print("Sending player message...")
	socket.put_utf8_string(message)
	print("Player message sent.")

func getMessageFromServer():
	# Check if can get message
	if !socket.is_connected_to_host():
		print("Failed to get message.  Not connected to server.")
		return
	# Obtain message
	var messageLen = $Parser.getMessageLength(socket)
	print(messageLen)
	var messageJson = socket.get_utf8_string(messageLen)
	print(messageJson)

	# Convert message to dictionary
	var messageDict = $Parser.decodeMessage(messageJson)
	# Decode message purpose and send appropriate signal
	var messageCode = messageDict[messageType]
	print(messageCode)
	match messageCode:
		MESSAGE_TYPES.VALID_SERVER_CODE:
			emit_signal("enteredValidHostCode")
		MESSAGE_TYPES.INVALID_SERVER_CODE:
			emit_signal("enteredInvalidHostCode")
		MESSAGE_TYPES.SERVER_FORCE_DISCONNECT_CLIENT:
			print("Forcibly disconnected from Host by Server.")
			disconnectPlayerFromServer()
		MESSAGE_TYPES.HOST_STARTING_GAME:
			emit_signal("gameStartedByHost")
		MESSAGE_TYPES.HOST_ENDING_GAME:
			emit_signal("gameEndedByHost")
		MESSAGE_TYPES.HOST_SENDING_PROMPT:
			emit_signal("promptsReceived", messageDict["promptArray"])
		MESSAGE_TYPES.HOST_SENDING_ANSWERS:
			emit_signal("answersReceived", messageDict["answerArray"])
		MESSAGE_TYPES.INVALID_USERNAME:
			emit_signal("enteredInvalidUsername")
		MESSAGE_TYPES.ACCEPTED_USERNAME_AND_AVATAR:
			emit_signal("enteredValidUsername")
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
		_:
			print("Unrecognized message code " + str(messageCode))
