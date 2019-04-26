extends HBoxContainer

onready var placeLabel = $PlaceLabel
onready var scoreLabel = $ScoreLabel
onready var nameLabel = $PlayerName
onready var avatarPic = $PlayerIcon

func update_display(place, score, username, avatarID):
	var avatarPath = AvatarIdToFilename.AvatarIdToFilenameDict[avatarID]
	
	match (place):
		1:
			placeLabel.text = "1st:"
		2:
			placeLabel.text = "2nd:"
		3:
			placeLabel.text = "3rd:"
		_:
			placeLabel.text = String( place ) + "th:"
	
	scoreLabel.text = String(score)
	nameLabel.text = username
	
	if (avatarPath != null):
		avatarPic.texture = load(avatarPath)
	else:
		avatarPic.texture = load(GlobalVars.DEFAULTAVATAR)