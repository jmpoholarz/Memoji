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


func _process(delta):
	# if connected, check for message
	if socket.get_status() == socket.STATUS_CONNECTED:
		#pass
		if socket.get_available_bytes() > 0:
			getMessageFromServer()

func connectHostToServer(serverIP, serverPort):
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
	socket.disconnect_from_host()
	emit_signal("_disconnectedFromServer")

func _on_ConnectingTimer_timeout():
	if socket.get_status() != socket.STATUS_CONNECTED:
		print(socket.get_status())
		print("Connection attempt failed.  Took too long to connect.")
		# Force disconnect
		disconnectHostFromServer()
	else:
		print(socket.get_status())
		print("Connection attempt was successful.")
		print("Now listening on " + defaultServerIP + ":" + str(defaultServerPort))
		sendMessageToServer("Test Message")

func sendMessageToServer(message):
	# Check if can send message
	if !socket.is_connected_to_host():
		print("Failed to send message.  Not connected to server.")
		return
	# Send message
	print("Send Message")
	socket.put_utf8_string(message)
	print("Message Sent")

func getMessageFromServer():
	# Check if can get message
	if !socket.is_connected_to_host():
		print("Failed to get message.  Not connected to server.")
		return
	# Obtain message
	var messageLen = socket.get_u32()
	print(messageLen)
	var messageJson = socket.get_utf8_string(messageLen)
	print(messageJson)
	
	# Convert message to dictionary
	var messageDict = $Parser.decodeMessage(messageJson)
	# Decode message purpose and send appropriate signal
	var messageCode = messageDict[messageType]
	print(messageCode)
	match messageCode:
		MESSAGE_TYPES.SERVER_SENDING_CODE:
			emit_signal("obtainedLetterCode", messageDict[letterCode])
			print(messageDict[letterCode])
		MESSAGE_TYPES.SERVER_PING:
			pass #TODO
		MESSAGE_TYPES.PLAYER_CONNECTED:
			pass #TODO
		MESSAGE_TYPES.PLAYER_DISCONNECTED:
			pass #TODO
		MESSAGE_TYPES.PLAYER_USERNAME_AND_AVATAR:
			pass #TODO
		MESSAGE_TYPES.PLAYER_SENDING_PROMPT_RESPONSE:
			pass #TODO
		MESSAGE_TYPES.PLAYER_SENDING_SINGLE_VOTE:
			pass #TODO
		MESSAGE_TYPES.PLAYER_SENDING_MULTI_VOTE:
			pass #TODO
		