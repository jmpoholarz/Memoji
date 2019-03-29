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
	var b1 = socket.get_u8()
	var b2 = socket.get_u8()
	var b3 = socket.get_u8()
	var b4 = socket.get_u8()
	
	total = (b1 * (16*16*16*16*16*16)) + (b2 * (16*16*16*16)) + (b3 * (16*16)) + (b4)
	
	return total