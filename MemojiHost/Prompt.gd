extends Node

var promptID
var text
var playerAnswers = []
var playerVotes = []

class Answer:
	var playerID
	var emojis

class Vote:
	var playerID
	var voteID

func getPlayers():
	players = []
	
	for ans in playerAnswers:
		players.append(ans.playerID)
		pass
	
	return players
	
func insertAnswer(playerID, emojiArray):
	ans = Answer.new()
	ans.playerID = playerID
	ans.emojis = emojiArray
	
	playerAnswers.append(ans)