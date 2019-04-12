var playerID
var username
var avatarID
var isPlayer

var vote = null # Who this player voted for: 0 for left, 1 for right
var totalScore = 0 # NEW - used to keep track of scores for final results
var currentPromptIDs = []

func reset_score():
	totalScore = 0

func increase_score(points):
	totalScore += points

func get_score():
	return totalScore

func clear_prompts():
	currentPromptIDs.clear()
	
func add_promptID(id):
	currentPromptIDs.append(id)

func get_promptIDs():
	return currentPromptIDs
