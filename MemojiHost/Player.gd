var playerID
var username
var avatarID
var isPlayer
var currentPromptIDs = []
var answeredPromptIDs = []

func clear_prompts():
	currentPromptIDs.clear()
	
func add_promptID(id):
	currentPromptIDs.append(id)

func get_promptIDs():
	return currentPromptIDs
