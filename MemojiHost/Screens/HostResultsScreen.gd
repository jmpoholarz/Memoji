extends Container

# class member variables go here
var score1 = 0
var score2 = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func displayAnswers(answers):
	#get the arrays of answers so that the responses can be displayed
	var displayBox = get_node("MarginContainer/Rows/AnswerBoxes/AnswerLeft/EmojiCanvas")
	displayBox.decode_emojis(answers[0])
	displayBox = get_node("MarginContainer/Rows/AnswerBoxes/AnswerRight/EmojiCanvas")
	displayBox.decode_emojis(answers[1])
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
		scoreToUpdate = get_node("MarginContainer/Rows/Results/ScoreLeft")
		scoreToUpdate.text = str(totalPoints)
		scoreToUpdate = get_node("MarginContainer/Rows/AudienceVotes/AudienceLeft")
		scoreToUpdate.text = (str(audiencePercent) + "%")
	elif ID == 2:
		score2 = totalPoints
		scoreToUpdate = get_node("MarginContainer/Rows/Results/ScoreRight")
		scoreToUpdate.text = str(totalPoints)
		scoreToUpdate = get_node("MarginContainer/Rows/AudienceVotes/AudienceRight")
		scoreToUpdate.text = (str(audiencePercent) + "%")
	return totalPoints

func displayVoters(leftPlayers, rightPlayers):
	#recieve who voted for each answer and display appropriately
	#location of the voter images
	#display the correct voter images that voted for each answer
	#voterLoc is the location in the scene where the voter display is located
	var voterLoc = "MarginContainer/Rows/Voters/"
	#current node being decided to make visible or invisible
	var currentNode
	#go through every player vote and decide which side to show them 
	var index = 0
	#first make every voter icon invisible so that only valid votes are shown
	for x in range(0, 8):
		currentNode = get_node(voterLoc + "VotersLeft/player" + str(index+1))
		currentNode.visible = false
		currentNode = get_node(voterLoc + "VotersRight/player" + str(index+1))
		currentNode.visible = false
	
	#show voters for the left response
	for x in leftPlayers:
		currentNode = get_node(voterLoc + "VotersLeft/player" + str(index+1))
		currentNode.visible = true
		currentNode = get_node(voterLoc + "VotersLeft/player" + str(index+1) + "/PlayerIcon")
		currentNode.texture = load("res://Assets/m" + str(leftPlayers[index].avatarID) + ".png")
		currentNode = get_node(voterLoc + "VotersLeft/player" + str(index+1) + "/Label")
		currentNode.text = leftPlayers[index].username
		index += 1
	
	index = 0
	
	#show voters for the right response
	for x in rightPlayers:
		currentNode = get_node(voterLoc + "VotersRight/player" + str(index+1))
		currentNode.visible = true
		currentNode = get_node(voterLoc + "VotersRight/player" + str(index+1) + "/PlayerIcon")
		currentNode.texture = load("res://Assets/m" + str(rightPlayers[index].avatarID) + ".png")
		currentNode = get_node(voterLoc + "VotersRight/player" + str(index+1) + "/Label")
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
