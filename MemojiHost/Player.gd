var playerID
var username
var avatarID
var isPlayer

var totalScore = 0 # NEW - used to keep track of scores for final results
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
	votes.resize(1)
	votes[0] = voteID
	
func multi_vote(goldVote, silverVote, bronzeVote):
	votes.resize(3)
	votes[0] = goldVote
	votes[1] = silverVote
	votes[2] = bronzeVote
	