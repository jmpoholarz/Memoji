extends Container

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
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

func calculateTotals(ID, votes, audiencePercent):
	#calculate how many points are to be awarded to the player based on
	#the number of votes received and the percent of the audience won over
	var totalPoints
	var scoreToUpdate
	#number of votes are multiplied by 100
	#audience percent is added as a percent of 100 points, a perfect audience score
	#is equal to that of two players
	totalPoints = (votes * 100) + (audiencePercent * 2)
	if ID == 1:
		score1 = totalPoints
		scoreToUpdate = get_node("MarginContainer/Rows/Results/ScoreLeft")
		scoreToUpdate.text = str(totalPoints)
	else:
		score2 = totalPoints
		scoreToUpdate = get_node("MarginContainer/Rows/Results/ScoreRight")
		scoreToUpdate.text = str(totalPoints)
	return totalPoints
	
func displayVoters(votes):
	#recieve who voted for each answer and display appropriately
	var currentNode = getNode("MarginContainer/Rows/Voters/VotersRight/PlayerIcon1")
	for x in range(0, votes.size()):
		if(votes[x] == 1):
			currentNode = getNode("MarginContainer/Rows/Voters/VotersLeft/PlayerIcon" + str(x+1))
			currentNode.visible = true
		elif(votes[x] == 2):
			currentNode = getNode("MarginContainer/Rows/Voters/VotersRight/PlayerIcon" + str(x+1))
			currentNode.visible = true
	return