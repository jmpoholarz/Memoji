extends Node

func encodeMessage(dictionary):
	"""
	Converts a dictionary message into Json format to be sent to the server
	Arguments:
		dictionary - the message in dictionary format
	Returns:
		json - the message in Json format
	"""
	var json = JSON.print(dictionary)
	return json

func decodeMessage(json):
	"""
	Converts a Json message from the server back into usable dictionary format
	Arguments:
		json - the message in Json format
	Returns:
		dictionary - the message in Dictionary format
	"""
	var dictionary = JSON.parse(json).result
	return dictionary

func getMessageLength(socket):
	"""
	Obtains the message length from the socket by mathing 4 bytes
	Arguments:
		socket - the stream connected to the server
	Returns:
		total - the value of the 4 bytes
	"""
	var total = 0
	for i in range(3, -1, -1):
		var byte = socket.get_u8()
		print(byte)
		total += (byte * int(pow(16,i)))
	return total

func testJsonConversions():
	var d1 = {"apple":1, "banana":"orange"}
	var j1 = JSON.print(d1)
	
	var d2 = JSON.parse(j1).result
	print(d2)
	