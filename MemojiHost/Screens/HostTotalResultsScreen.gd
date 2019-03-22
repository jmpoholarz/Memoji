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
	
	return
