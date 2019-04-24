extends Container

# First 2 required by ScreenManager
signal messageServer(msg)
signal changeScreen(screen)
signal updateGameState(msg)

var leftColumnPlace = "MarginContainer/Rows/Columns/ResultsLeft/Place"
var rightColumnPlace = "MarginContainer/Rows/Columns/ResultsRight/Place"

onready var resultsLeftNode = $MarginContainer/Rows/Columns/ResultsLeft
onready var resultsRightNode = $MarginContainer/Rows/Columns/ResultsRight

var playerDispArr = [] # stores the nodes displying player ranking
var PlaceDisplayScene = preload("res://Screens/Elements/PlaceDisplay.tscn")

func _ready():
	
	return
	
func displayResultsOld(scores, players):
	#duplicate the scores to be sorted into highest to lowest
	var ordered = [] + scores
	var temp
	ordered.append(0)
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
	var displayPlace = 2
	var lastScore = ordered[0]
	var remainingPlayers = [] + players
	var currentIndex = 0
	var currentPlace = 1
	var placeNode = get_node("MarginContainer/Rows/Columns/ResultsLeft/Place1")
	var placeNodeLabel
	var placeNodeText
	var placeNodeIcon
	#while there are still players that have not been placed
	while(ordered.size() != 1):
		#find the highest score remaining in the array
		for i in range(0, scores.size()):
			if(scores[i] == ordered[0]):
				currentIndex = i
		#place the player in their correct place, displaying their place, making sure they are visible
		if(ordered[0] == lastScore):
			displayPlace -= 1
		if(currentPlace < 5):
			placeNode = get_node(leftColumnPlace + str(currentPlace))
			placeNodeLabel = get_node(leftColumnPlace + str(currentPlace)+"/PlaceLabel")
			placeNodeText = get_node(leftColumnPlace + str(currentPlace) + "/PlayerName")
			placeNodeIcon = get_node(leftColumnPlace + str(currentPlace) + "/PlayerIcon")
			placeNodeLabel.text = str(displayPlace)+":"
			placeNodeText.text = remainingPlayers[currentIndex].username + " scored " + str(ordered[0])
			lastScore = ordered[0]
			placeNodeIcon.texture = load("res://Assets/m"+ str(remainingPlayers[currentIndex].avatarID) +".png")
			placeNode.visible = true
		else:
			placeNode = get_node(rightColumnPlace + str(currentPlace))
			placeNodeLabel = get_node(rightColumnPlace+str(currentPlace)+"/PlaceLabel")
			placeNodeText = get_node(rightColumnPlace + str(currentPlace) + "/PlayerName")
			placeNodeIcon = get_node(rightColumnPlace + str(currentPlace) + "/PlayerIcon")
			placeNodeLabel.text = str(displayPlace)+":"
			placeNodeText.text = remainingPlayers[currentIndex].username + " scored " + str(ordered[0])
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

func displayResults(players):
	var arr = []
	var temp # for swaps
	var subIndex
	var dispNode
	
	arr = players.duplicate() # make a copy for sorting
	
	# Insertion Sort by total score
	
	for index in range(arr.size()):
		subIndex = index
		temp = arr[index]
		while (subIndex > 0):
			if (temp.get_total_score() > arr[subIndex - 1].get_total_score()):
				arr[subIndex] = arr[subIndex - 1]
			else:
				break
			subIndex -= 1
		arr[subIndex] = temp
		
	for index in range(arr.size()):
		dispNode = PlaceDisplayScene.instance()
		if (index < 4):
			resultsLeftNode.add_child(dispNode)
		else:
			resultsRightNode.add_child(dispNode)
		
		dispNode.update_display( index + 1, arr[index].username, arr[index].avatarID )
		dispNode.show()
	

func _on_ProceedButton_pressed():
	print("DEBUG: sent message to advance")
	emit_signal("updateGameState", "advance")
