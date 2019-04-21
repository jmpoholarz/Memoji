var playerID
var username
var avatarID
var isPlayer

var roundScore = 0 # NEW - used to keep track of scores for each round
var totalScore = 0 # Total across all rounds
var currentPromptIDs = []
var answeredPromptIDs = []
var votes = [] # Array for votes; During regular rounds, only contains 1 element
# During Final Round, contains 3 elements in order of [Gold, Silver, Bronze]

func reset_score():
	totalScore = 0

func increase_score(points):
	totalScore += points

func get_score():
	return totalScore

func clear_prompts():
	currentPromptIDs.clear()
	answeredPromptIDs.clear() # NEW - clears both arrays now
	
func add_promptID(id):
	currentPromptIDs.append(id)

func get_promptIDs():
	return currentPromptIDs

# Voting #

func clear_vote():
	votes.clear()

func regular_vote(voteID):
	var isNew # True if it's the first time a player updates their vote
	if (votes.size() > 0):
		isNew = false
	else:
		isNew = true
	
	votes.resize(1)
	votes[0] = voteID
	
	return isNew
	
func multi_vote(goldVote, silverVote, bronzeVote):
	votes.resize(3)
	votes[0] = goldVote
	votes[1] = silverVote
	votes[2] = bronzeVote

func check_vote(final = false):
	if (votes.size() < 1):
		return false
	
	if (final && votes.size() < 3):
		return false
	
	return true