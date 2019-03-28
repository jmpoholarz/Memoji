extends Container

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func displayResults(scores, players):
	#TODO
	#duplicate the scores to be sorted into highest to lowest
	var ordered = [] + scores
	var temp
	#sort through the scores to put them in order
	for x in range(1, ordered.size()):
		var y = x
		while(y > 0 && ordered[y-1] > ordered[y]):
			temp = ordered[y-1]
			ordered[y-1] = ordered[y]
			ordered[y] = temp
			y -= 1
	#place every player is their correct location, and make them visible
	var remainingPlayers = [] + players
	var currentIndex = 0
	var currentPlace = 1
	var placeNode = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place1")
	#while there are still players that have not been placed
	while(remainingPlayers.empty() == false):
		#find the highest score remaining in the array
		for i in range(0, scores.size()):
			if(scores[i] == ordered[0]):
				currentIndex = i
		#place the player in their correct place, displaying their place, making sure they are visible
		if(currentPlace < 5):
			placeNode = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place" + str(currentPlace) + "/PlayerName")
			placeNode.text = remainingPlayers[currentIndex].username
			placeNode.visible = true
		else:
			placeNode = get_node("MarginContainer/Rows/Columns/ResultsRight/Place" + str(currentPlace) + "/PlayerName")
			placeNode.text = remainingPlayers[currentIndex].username
			placeNode.visible = true
		#remove the score and player from the list of remaining players to be displayed
		ordered.remove(0)
		remainingPlayers.remove(0)
		#set the score to -1 so that it cannot be the highest score again,
		#this is for making sure if two players are tied, then whichever 
		#player has the higher index is not displayed twice
		scores[currentIndex] = -1
		#move to next place
		currentIndex = 0
		currentPlace += 1
	
	return
