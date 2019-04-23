extends VBoxContainer

onready var _PlayerNameLabel = $PlayerNameLabel
onready var _EmojiCanvas = $VBoxContainer/EmojiCanvas
onready var _GoldIcon = $VBoxContainer/MedalDisplay/GoldContainer/GoldIcon
onready var _GoldLabel = $VBoxContainer/MedalDisplay/GoldContainer/GoldLabel
onready var _SilverIcon = $VBoxContainer/MedalDisplay/SilverContainer/SilverIcon
onready var _SilverLabel = $VBoxContainer/MedalDisplay/SilverContainer/SilverLabel
onready var _BronzeIcon = $VBoxContainer/MedalDisplay/BronzeContainer/BronzeIcon
onready var _BronzeLabel = $VBoxContainer/MedalDisplay/BronzeContainer/BronzeLabel
onready var _PointsLabel = $VBoxContainer/PointsLabel

var number_of_gold = 0
var number_of_silver = 0
var number_of_bronze = 0
var points = 0

func set_player_name(name):
	_PlayerNameLabel.text = name

func get_player_name():
	return _PlayerNameLabel.text

func decode_emojis(emojis):
	_EmojiCanvas.decode_emojis(emojis)

func set_golds(number):
	number_of_gold = number
	if number_of_gold > 0:
		_GoldIcon.visible = true
		_GoldLabel.visible = true
		_GoldLabel.text = str(number_of_gold)
	else:
		_GoldIcon.visible = false
		_GoldLabel.visible = false

func get_golds():
	return number_of_gold

func set_silvers(number):
	number_of_silver = number
	if number_of_silver > 0:
		_SilverIcon.visible = true
		_SilverLabel.visible = true
		_SilverLabel.text = str(number_of_silver)
	else:
		_SilverIcon.visible = false
		_SilverLabel.visible = false

func get_silvers():
	return number_of_silver

func set_bronzes(number):
	number_of_bronze = number
	if number_of_bronze > 0:
		_BronzeIcon.visible = true
		_BronzeLabel.visible = true
		_BronzeLabel.text = str(number_of_bronze)
	else:
		_BronzeIcon.visible = false
		_BronzeLabel.visible = false

func get_bronzes():
	return number_of_bronze

func set_points(points):
	self.points = points
	_PointsLabel.text = str(points) + " Points"

func get_points():
	return points
