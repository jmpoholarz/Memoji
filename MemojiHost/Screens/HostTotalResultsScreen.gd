extends Container


func displayResults(scores, players):
	#duplicate the scores to be sorted into highest to lowest
	var ordered = [] + scores
	var temp
	#sort through the scores to put them in order
	for x in range(1, ordered.size()):
		var y = x
		while(y > 0 && ordered[y-1] < ordered[y]):
			temp = ordered[y-1]
			ordered[y-1] = ordered[y]
			ordered[y] = temp
			y -= 1
	#place every player is their correct location, and make them visible
	#displayPlace is the displayed place of players
	var tieWithPrev = false
	ordered.append(0)
	var displayPlace = 1
	var lastScore = ordered[0]
	var remainingPlayers = [] + players
	var currentIndex = 0
	var currentPlace = 1
	var placeNode = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place1")
	var placeNodeText
	var placeNodeIcon
	#while there are still players that have not been placed
	while(remainingPlayers.size() != 1):
		#find the highest score remaining in the array
		for i in range(0, scores.size()):
			if(scores[i] == ordered[0]):
				currentIndex = i
		#place the player in their correct place, displaying their place, making sure they are visible
		if(currentPlace < 5):
			placeNode = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place" + str(currentPlace))
			placeNodeLabel = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place"+str(currentPlace)+"/PlaceLabel")
			placeNodeText = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place" + str(currentPlace) + "/PlayerName")
			placeNodeIcon = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place" + str(currentPlace) + "/PlayerIcon")
			placeNodeText.text = remainingPlayers[currentIndex].username + ":  " + str(ordered[0])
			lastScore = ordered[0]
			placeNodeIcon.texture = load("res://Assets/m"+ str(remainingPlayers[currentIndex].avatarID) +".png")
			placeNode.visible = true
		else:
			placeNode = get_node("MarginContainer/Rows/Columns/ResultsRight/Place" + str(currentPlace))
			placeNodeLabel = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place"+str(currentPlace)+"/PlaceLabel")
			placeNodeText = get_node("MarginContainer/Rows/Columns/ResultsRight/Place" + str(currentPlace) + "/PlayerName")
			placeNodeIcon = get_node("MarginContainer/Rows/Columns/ResultsRight/Place" + str(currentPlace) + "/PlayerIcon")
			placeNodeText.text = remainingPlayers[currentIndex].username + ":  " + str(ordered[0])
			lastScore = ordered[0]
			placeNodeIcon.texture = load("res://Assets/m"+ str(remainingPlayers[currentIndex].avatarID) +".png")
			placeNode.visible = true
		#remove the score and player from the list of remaining players to be displayed
		ordered.remove(0)
		remainingPlayers.remove(currentIndex)
		#set the score to -1 so that it cannot be the highest score again,
		#this is for making sure if two players are tied, then whichever 
		#player has the higher index is not displayed twice
		scores.remove(currentIndex) #scores[currentIndex] = -1
		#move to next place
		currentIndex = 0
		currentPlace += 1
		displayPlace += 1
	return
