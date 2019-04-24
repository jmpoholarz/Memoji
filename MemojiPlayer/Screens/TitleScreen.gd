extends Panel

signal connectToServer()
signal sendMessage(msg)
signal updateLetterCode(letter_code)


onready var _JoinButton = $VBoxContainer/JoinButton
onready var _InstructionsLabel = $VBoxContainer/InstructionsLabel
onready var _RoomCodeLineEdit = $VBoxContainer/RoomCodeLineEdit
onready var _ConnectingLabel = $ConnectingLabel
# Popups
onready var _RoomCodeInvalidLengthPopup = $RoomCodeInvalidLengthPopup
onready var _RoomCodeInvalidCharacterPopup = $RoomCodeInvalidCharacters
onready var _ServerErrorPopup = $ServerErrorPopup
onready var _ReconnectPopup = $ReconnectPopup
# Notification Buttons
onready var _ReconnectNotification = $NotificationContainer/ReconnectNotification

var game_info = null

func _ready():
	# Check if there's an unfinished game session
	game_info = SessionStorer.load_game_info()
	if game_info["player_id"] != "" && game_info["letter_code"] != "":
		_ReconnectPopup.popup()

func _on_JoinButton_pressed():
	var roomCode = _RoomCodeLineEdit.text
	# Check for correct length
	if roomCode.length() != 4:
		_RoomCodeInvalidLengthPopup.popup()
		return
	# Check if only alpha characters
	roomCode = roomCode.to_upper()
	for i in range(roomCode.length()):
		match roomCode[i]:
			'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M':
				pass
			'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z':
				pass
			_:
				_RoomCodeInvalidCharacterPopup.popup()
				return
	
	# Handle valid room code
	print(roomCode)
	_InstructionsLabel.text = roomCode
	var msg = {
		"messageType": MESSAGE_TYPES.PLAYER_CONNECTED,
		"letterCode": roomCode
	}
	emit_signal("connectToServer")
	_ConnectingLabel.visible = true
	_JoinButton.disabled = true
	yield(get_tree().create_timer(2), "timeout")
	emit_signal("sendMessage", msg)


func _on_InvalidRoomCode():
	_ConnectingLabel.visible = false
	_JoinButton.disabled = false
	_RoomCodeInvalidCharacterPopup.popup()
	
func show_ServerErrorPopup(text):
	_ConnectingLabel.visible = false
	_JoinButton.disabled = false
	$ServerErrorPopup/Label.text = text
	_ServerErrorPopup.popup()


func _on_YesReconnectButton_pressed():
	print("[DEBUG]: Reconnect to previous host")
	print("[DEBUG]: " + game_info["letter_code"])
	print("[DEBUG]: " + game_info["player_id"])
	var message = {
		"messageType": 406,
		"letterCode": game_info["letter_code"],
		"playerID": game_info["player_id"]
	}
	emit_signal("sendMessage", message)
	_ReconnectPopup.hide()
	_ConnectingLabel.visible = true
	pass # replace with function body

func _on_NoReconnectButton_pressed():
	_ReconnectPopup.hide()

func _on_ReconnectPopup_popup_hide():
	_ReconnectNotification.visible = true

func _on_ReconnectNotification_pressed():
	_ReconnectNotification.visible = false
	_ReconnectPopup.popup()
