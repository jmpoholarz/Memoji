extends Node

var errorFile

func _ready():
	errorFile = File.new()
	writeLaunchDetails()

func writeLaunchDetails():
	var success = errorFile.open("user://log.txt", File.READ_WRITE)
	if success != 0:
		print("Error opening log file.  Creating new file.")
		errorFile.open("user://log.txt", File.WRITE)
	errorFile.seek_end()
	var timeDict = OS.get_datetime()
	errorFile.store_line("- - - - - Memoji Host - - - - -\r\n")
	errorFile.store_line("Running at " + getDateTimeString() + "\r\n")
	errorFile.store_line("- - - - - - - - - - - - - - - -\r\n")
	errorFile.close()

func getDateTimeString():
	var timeDict = OS.get_datetime()
	var minute = timeDict["minute"]
	if minute < 10:
		minute = "0" + str(minute)
	var timeString = str(timeDict["hour"]) + ":" + str(minute) + " on " +  \
		str(timeDict["month"]) + "/" + str(timeDict["day"]) + "/" + str(timeDict["year"])
	return timeString

func getTimeString():
	var timeDict = OS.get_datetime()
	var minute = timeDict["minute"]
	if minute < 10:
		minute = "0" + str(minute)
	var timeString = str(timeDict["hour"]) + ":" + str(minute)
	return timeString

func writeLine(string):
	errorFile.open("user://log.txt", File.READ_WRITE)
	errorFile.seek_end()
	errorFile.store_string(string + "\r\n")
	errorFile.close()

func write(string):
	errorFile.open("user//log.txt", File.READ_WRITE)
	errorFile.seek_end()
	errorFile.store_string(string)
	errorFile.close()

