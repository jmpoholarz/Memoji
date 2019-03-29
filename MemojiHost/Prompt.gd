var prompt_id
var prompt_text
var player_answers = []
var player_votes = []

class Answer:
	var player_id
	var emojis

class Vote:
	var player_id
	var vote_index

# Getters

func get_prompt_id():
	return prompt_id

func get_prompt_text():
	return prompt_text

func get_answers():
	return player_answers

func get_votes():
	return player_votes

func get_answer_from_player(player_id):
	for answer in player_answers:
		if answer.player_id == player_id:
			return answer.emojis

func get_vote_from_player(player_id):
	for vote in player_votes:
		if vote.player_id == player_id:
			return vote.vote_index

func get_number_of_votes_for_answer(answer_index):
	var counter = 0
	for vote in player_votes:
		if vote.vote_index == answer_index:
			counter += 1
	return counter

func get_players_who_answered():
	var players = []
	for index in range(player_answers.size()):
		players.append(player_answers[index].player_id)
	return players

func get_players_who_voted():
	var players = []
	for vote in player_votes:
		players.append(vote.player_id)
	return players

func get_voters_for_answer(answer_index):
	var supporters = []
	for vote in player_votes:
		if (vote.vote_index == answer_index):
			supporters.append(vote.player_id)
	return supporters

# Setters

func set_prompt_id(prompt_id):
	self.prompt_id = prompt_id

func set_prompt_text(prompt_text):
	self.prompt_text = prompt_text

func add_player_answer(player_id, emojis):
	for answer in player_answers:
		if (answer.player_id == player_id): # Update the answer, do not add new answer
			answer.emojis = emojis
			return
	
	# Create object to hold answer
	var answer_obj = Answer.new()
	answer_obj.player_id = player_id
	answer_obj.emojis = emojis
	# Store answer and add as a child
	player_answers.append(answer_obj)
	

func add_player_vote(player_id, vote_index):
	for vote in player_votes:
		if (vote.player_id == player_id): # Update duplicate vote
			vote.vote_index = vote_index
			return
	
	# Create object to hold vote
	var vote_obj = Vote.new()
	vote_obj.player_id = player_id
	vote_obj.vote_index = vote_index
	# Store vote and add as a child
	player_votes.append(vote_obj)