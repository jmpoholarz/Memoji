extends Node

var titleScreenScene = preload("res://TitleScreen.tscn")
var userinfoScreenScene = preload("res://UserInformationScreen.tscn")
var lobbyScreenScene = preload("res://WaitngForGameScreen.tscn")

signal sendMessageToServer(msg)
signal connectToServer()

enum SCREENS {
	TITLE_SCREEN = 1,
	USERINFORMATION_SCREEN = 2,
	LOBBY_SCREEN = 3
	
}

var currentScreen
var currentScreenInstance

func _ready():
	pass

func changeScreenTo(screen):
	# TODO - queue_free() before changing screen
	match screen:
		TITLE_SCREEN:
			currentScreenInstance = titleScreenScene.instance()
			add_child(currentScreenInstance)
			currentScreenInstance.connect("connectToServer", self, "connectToServer")
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			
		USERINFORMATION_SCREEN:
			currentScreenInstance = userinfoScreenScene.instance()
			add_child(currentScreenInstance)
			#currentScreenInstance.connect("connectToServer", self, "connectToServer")
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			var GSM = get_node("../")
			currentScreenInstance.change_name_and_icon(GSM.playerName, GSM.playerIcon)
		
		LOBBY_SCREEN:
			currentScreenInstance = lobbyScreenScene.instance()
			add_child(currentScreenInstance)
			currentScreenInstance.connect("sendMessage", self, "forwardMessage")
			currentScreenInstance.connect("changeScreen", self, "changeScreenTo")
			currentScreenInstance.connect("disconnectFromHost", self, "disconnectFromServer")
	currentScreen = screen

func forwardMessage(msg):
	#print("in forward message with message " + str(msg))
	emit_signal("sendMessageToServer", msg)

func connectToServer():
	#print("in ScreenManager connectToServer")
	emit_signal("connectToServer")

func disconnectFromServer():
	emit_signal("disconnectFromServer")