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

func calculateTotals(votes, audiencePercent):
	#calculate how many points are to be awarded to the player based on
	#the number of votes received and the percent of the audience won over
	var totalPoints
	#number of votes are multiplied by 100
	#audience percent is added as a percent of 100 points, a perfect audience score
	#is equal to that of one player
	totalPoints = (votes * 100) + audiencePercent
	return totalPoints
	