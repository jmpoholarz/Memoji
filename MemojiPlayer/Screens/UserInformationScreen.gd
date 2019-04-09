extends Panel
# Preloads
var AvatarButtonScene = preload("res://Screens/Elements/AvatarSelectionSubElements/AvatarButton.tscn")
var AvatarButtonGroup = preload("res://Screens/Elements/AvatarSelectionSubElements/AvatarButtonGroup.tres")
# Signals
signal sendMessage(message)
# Constants
var NUMBER_OF_AVATARS = 8
var BUTTON_SIZE = 100
# Onreadys
onready var _TextBox = $MarginContainer/VBoxContainer/HBoxContainer/TextEdit
onready var _TextureRect = $MarginContainer/VBoxContainer/HBoxContainer/AvatarTextureRect
onready var _SubmitButton = $MarginContainer/VBoxContainer/MarginContainer/SubmitButton
onready var _GridContainer = $MarginContainer/VBoxContainer/VBoxContainer2/ScrollContainer/GridContainer

onready var _UsernameErrorPopup = $UsernameErrorPopup
onready var _AvatarErrorPopup = $AvatarErrorPopup
# Variables
var avatar_id = -1
var username = ""

func _ready():
	# Update grid columns to adjust to screen size
	update_columns()
	_insert_avatars()


func update_columns():
	_GridContainer.columns = _GridContainer.rect_size.x / BUTTON_SIZE
	if _GridContainer.columns < 1:
		_GridContainer.columns = 1


func _insert_avatars():
	for i in range(NUMBER_OF_AVATARS):
		var id = int(1000 + i * 100)
		var avatar_button_instance = AvatarButtonScene.instance()
		avatar_button_instance.avatar_id = id
		avatar_button_instance.icon = load(AvatarIdToFilename.AvatarIdToFilenameDict[id])
		avatar_button_instance.toggle_mode = true
		avatar_button_instance.group = AvatarButtonGroup
		avatar_button_instance.connect("avatar_button_pressed", self, "_on_avatar_button_pressed")
		_GridContainer.add_child(avatar_button_instance)


func _on_avatar_button_pressed(id):
	avatar_id = id
	# Update avatar display
	_TextureRect.texture = load(AvatarIdToFilename.AvatarIdToFilenameDict[avatar_id])


func _on_TextEdit_text_changed():
	username = _TextBox.text


func textSubmitToServer(message):
	emit_signal("sendMessage", message)


func _on_SubmitButton_pressed():
	if username.length() <= 0:
		_UsernameErrorPopup.popup()
		return
	if avatar_id == -1:
		_AvatarErrorPopup.popup()
		return
	
	print(username + " " + str(avatar_id))
	var msg = {
		"messageType": MESSAGE_TYPES.PLAYER_USERNAME_AND_AVATAR,
		"username": username,
		"avatarIndex": avatar_id
	}
	#emit_signal("connectToServer")
	#yield(get_tree().create_timer(2), "timeout")
	emit_signal("sendMessage", msg)

