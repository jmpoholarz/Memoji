extends Node

enum MESSAGE_TYPES {
	#CONNECTED_TO_SERVER = 600,
	
	HOST_REQUESTING_CODE = 110,				# Sent from host when setting up server
	SERVER_SENDING_CODE = 111,				# Sent when first delivering ABCD code
	INVALID_SERVER_CODE = 112,				# Sent when player enters an invalid code
	
	SERVER_PING = 120,						# Sent when server is checking if the game is still active
	HOST_RESPONDING_TO_PING = 121,			# Sent when host tells the server it's still handing games
	
	HOST_SHUTTING_DOWN = 130,				# Sent when host has closed their game session
	SERVER_FORCE_DISCONNECT_CLIENT = 131,	# Sent when the server forces a player to disconnect
	
	HOST_STARTING_GAME = 301,				# Sent to advance players to blank screen before prompts
	HOST_ENDING_GAME = 302,					# Sent to advance players back to join game screen where they can quit
	HOST_SENDING_PROMPT = 311,				# Sent to move players to a prompt answering screen
	HOST_SENDING_ANSWERS = 312,				# Sent to move players to a screen to vote on answers
	HOST_TIME_UP = 320,						# Sent to move players to black screen @ prompt/vote timer expires
	
	PLAYER_CONNECTED = 401,					# Sent from player to inform of new player connection
	PLAYER_DISCONNECTED = 402,				# Sent from player to inform of disconnect from server, such as quitting	
	PLAYER_USERNAME_AND_AVATAR = 403,		# Sent to update player's username and avatar on the host
	INVALID_USERNAME = 404,					# Sent when an entered username is already taken or invalid
	ACCEPTED_USERNAME_AND_AVATAR = 405,		# Sent when an entered username/avatar are valid
	
	PLAYER_SENDING_PROMPT_RESPONSE = 410,	# Sent to deliver an answer to a prompt to the host
	INVALID_PROMPT_RESPONSE = 411,			# Sent when a prompt response is invalid
	ACCEPTED_PROMPT_RESPONSE = 412,			# Sent when server successfully obtains a player response to a prompt
	PLAYER_SENDING_SINGLE_VOTE = 420,		# Sent to deliver an answer to a vote to the host
	INVALID_VOTE_RESPONSE = 421,			# Sent when a vote response is invalid
	ACCEPTED_VOTE_RESPONSE = 422,			# Sent when a vote response is successfully obtained by the host
	PLAYER_SENDING_MULTI_VOTE = 430,		# Sent to deliver an answer to the final round to the host 
	INVALID_MULTI_VOTE = 431,				#
	ACCEPTED_MULTI_VOTE = 432,				#
	
	FINAL # Honestly just here so I don't have to re-add the comma etc.
}

"""
# # # # # # # # # # # # # # #
# Message Dictionary Fields #
# # # # # # # # # # # # # # # 
::: ALWAYS MUST BE ADDED :::
messageType				- The constand value for the type of message being sent to/from the server
letterCode				- The ABCD code the host should display on screen, generated by the server
::::::::::::::::::::::::::::
prompt					- A string message for the prompt to display on the player screens
promptArray				- An array of multiple string prompts to display one after another
promptID				- The ID number of a given prompt, generated by the host
emojiArray				- An array of [emojiID, xCoord, yCoord] representing user emoji placements
answers					- An array of emoji arrays representing user answers
playerID				- The ID number of a given player, generated by the server
username				- The string username chosen by a player to represent themselves on the host
avatarIndex				- The ID of the avatar image chosen to represent a player on the host
voteID					- The ID of the answer the player has chosen to vote for
voteArray				- An array of voteIDs that the player has chosen to vote for
"""