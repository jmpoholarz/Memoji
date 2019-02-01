extends Node

# # # Signals # # #
signal connectedToServer
signal disconnectedFromServer
signal obtainedLetterCode
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
		pass
		#if socket.get_available_bytes() > 0:
		#	getMessageFromServer()

func connectHostToServer(serverIP, serverPort):
	if !socket.is_connected_to_host():
		$ConnectingTimer.start()
		var response = socket.connect_to_host(serverIP, serverPort)
		print(socket.get_status())
		if response == FAILED:
			print("Connection attempt failed.")
		elif response == OK:
			print("Connection attempt made on " + defaultServerIP + ":" + str(defaultServerPort))
			emit_signal("connectedToServer")

func disconnectHostFromServer():
	socket.disconnect_from_host()
	emit_signal("disconnectedFromServer")

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

func sendMessageToServer(message):
	# Check if can send message
	if !socket.is_connected_to_host():
		print("Failed to send message.  Not connected to server.")
		return
	# Send message
	socket.put_utf8_string(message)

func getMessageFromServer():
	# Check if can get message
	if !socket.is_connected_to_host():
		print("Failed to get message.  Not connected to server.")
		return
	# Obtain message
	var message = socket.get_utf8_string()