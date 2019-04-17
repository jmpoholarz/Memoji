extends Container

signal updateGameState(msg)

# class member variables go here
var score1 = 0
var score2 = 0

onready var votersLeftNode = $MarginContainer/Rows/Voters/VotersLeft
onready var votersRightNode = $MarginContainer/Rows/Voters/VotersRight
onready var leftDisplayBox = $MarginContainer/Rows/AnswerBoxes/AnswerLeft/EmojiCanvas
onready var rightDisplayBox = $MarginContainer/Rows/AnswerBoxes/AnswerRight/EmojiCanvas

onready var scoreLeftLabel = $MarginContainer/Rows/Results/ScoreLeft
onready var scoreRightLabel = $MarginContainer/Rows/Results/ScoreRight
onready var audienceLeftLabel = $MarginContainer/Rows/AudienceVotes/AudienceLeft
onready var audienceRightLabel = $MarginContainer/Rows/AudienceVotes/AudienceRight

# Stores the player1, player2... nodes for easier access updated in ready
var votersLeftArr = []
var votersRightArr = []

func _ready():
	for index in range(votersLeftNode.get_child_count()):
		votersLeftArr.append(votersLeftNode.get_child(index))
		
	for index in range(votersRightNode.get_child_count()):
		votersLeftArr.append(votersLeftNode.get_child(index))

func displayAnswers(answers):
	#get the arrays of answers so that the responses can be displayed
	leftDisplayBox.decode_emojis(answers[0])
	rightDisplayBox.decode_emojis(answers[1])
	return

func calculateTotals(ID, votes, audiencePercent):
	#calculate how many points are to be awarded to the player based on
	#the number of votes received and the percent of the audience won over
	#also display the results on the screen elements
	var totalPoints
	#scoreToUpdate is the node that is being worked with, either left or right
	var scoreToUpdate
	#number of votes are multiplied by 100
	#audience percent is added as a percent of 100 points, a perfect audience score
	#is equal to that of two players
	totalPoints = (votes * 100) + (audiencePercent * 2)
	#set the score of whichever was calculated to be shown
	if ID == 1:
		score1 = totalPoints
		scoreLeftLabel.text = str(totalPoints)
		audienceLeftLabel.text = (str(audiencePercent) + "%")
	elif ID == 2:
		score2 = totalPoints
		scoreRightLabel.text = str(totalPoints)
		audienceRightLabel.text = (str(audiencePercent) + "%")
	return totalPoints

func displayVoters(leftPlayers, rightPlayers):
	#recieve who voted for each answer and display appropriately
	#location of the voter images
	#display the correct voter images that voted for each answer
	#voterLoc is the location in the scene where the voter display is located
	#var voterLoc = "MarginContainer/Rows/Voters/"
	#current node being decided to make visible or invisible
	var currentNode
	#go through every player vote and decide which side to show them 
	var index = 0
	#first make every voter icon invisible so that only valid votes are shown
	for x in range(0, 8):
		currentNode = votersLeftArr[x]
		currentNode.visible = false
		currentNode = votersRightArr[x]
		currentNode.visible = false
	
	# TODO: Delun - Redo the for loop
	#show voters for the left response
	for x in leftPlayers:
		# NEW - Error checking - Note: works on a run
		if (x != null):
			currentNode = votersLeftArr[index]
			currentNode.visible = true
			currentNode = votersLeftArr[index].get_node("PlayerIcon")
			# NEW - test this
			currentNode.texture = load(AvatarIdToFilename.AvatarIdToFilenameDict[x.avatarID])
			currentNode = votersLeftArr[index].get_node("Label")
			currentNode.text = x.username
			index += 1
	
	index = 0
	
	#show voters for the right response
	for x in rightPlayers:
		if (x != null):
			currentNode = votersRightArr[index]
			currentNode.visible = true
			currentNode = votersRightArr[index].get_node("PlayerIcon")
			# NEW - test this
			currentNode.texture = load(AvatarIdToFilename.AvatarIdToFilenameDict[x.avatarID])
			currentNode = votersRightArr[index].get_node("Label")
			currentNode.text = rightPlayers[index].username
			index += 1
	
#	for x in range(0, votes.size()):
#		if(votes[x] == 1):
#			currentNode = get_node(voterLoc + "VotersLeft/PlayerIcon" + str(x+1))
#			currentNode.texture = load("res://Assets/m"+ str(players[x].avatarID) +".png")
#			currentNode.visible = true
#		elif(votes[x] == 2):
#			currentNode = get_node(voterLoc + "VotersRight/PlayerIcon" + str(x+1))
#			currentNode.texture = load("res://Assets/m"+ str(players[x].avatarID) +".png")
#			currentNode.visible = true
#		else:
#			#if a player did not vote make sure they are not visible
#			currentNode = get_node(voterLoc + "VotersLeft/PlayerIcon" + str(x+1))
#			currentNode.visible = false
#			currentNode = get_node(voterLoc + "VotersRight/PlayerIcon" + str(x+1))
#			currentNode.visible = false
	return

func displayAudience(votes):
	#TODO
	#votes is an array, index 0 contains votes for left, index 1 contains votes for right
	#display the percent of audience that voted for each answer in text boxes
	return


func _on_ProceedButton_pressed():
	emit_signal("updateGameState", "advance")
