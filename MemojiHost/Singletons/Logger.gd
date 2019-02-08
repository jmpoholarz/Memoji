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
	var timeDict = OS.get_datetime()
	errorFile.store_line("- - - Memoji Host - - -")
	errorFile.store_line("Running at " + getTimeString())
	errorFile.store_line("- - - - - - - - - - - -")
	errorFile.close()

func getTimeString():
	var timeDict = OS.get_datetime()
	var minute = timeDict["minute"]
	if minute < 10:
		minute = "0" + minute
	var timeString = str(timeDict["hour"]) + ":" + str(minute) + "on" +  \
		str(timeDict["month"]) + "/" + str(timeDict["day"]) + str(timeDict["year"])
	return timeString