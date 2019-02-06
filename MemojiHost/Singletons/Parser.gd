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

func testJsonConversions():
	var d1 = {"apple":1, "banana":"orange"}
	var j1 = JSON.print(d1)
	
	var d2 = JSON.parse(j1).result
	print(d2)
	