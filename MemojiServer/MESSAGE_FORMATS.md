# Message Formats

## Messages Sent from Host:
* **HOST_REQUESTING_CODE = 110**  
_Sent from host when setting up server_  
```javascript
{
  messageType: 110,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **HOST_RESPONDING_TO_PING = 121**  
_Sent when host tells the server it's still handing games_  
```javascript
{
  messageType: 121,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **HOST_SHUTTING_DOWN = 130**  
_Sent when host has closed their game session_  
```javascript
{
  messageType: 130,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **HOST_STARTING_GAME = 301**  
_Sent to advance players to blank screen before prompts_  
```javascript
{
  messageType: 301,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **HOST_ENDING_GAME = 302**  
_Sent to advance players back to join game screen where they can quit_  
```javascript
{
  messageType: 302,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **HOST_SENDING_PROMPT = 311**  
_Sent to move players to a prompt answering screen_  
```javascript
{
  messageType: 311,
  letterCode: "ABCD", (Added by Networking.gd)
  promptID: 1,
  prompt: "Some prompt string"
  playerID: "abc-123"
}
```

* **HOST_SENDING_ANSWERS = 312**  
_Sent to move players to a screen to vote on answers_  
```javascript
{
  messageType: 312,
  letterCode: "ABCD" (Added by Networking.gd)
  answers: [...]
}
```

* **HOST_TIME_UP = 320**  
_Sent to move players to black screen @ prompt/vote timer expires_  
```javascript
{
  messageType: 320,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **INVALID_USERNAME = 404**  
_Sent when an entered username is already taken or invalid_  
```javascript
{
  messageType: 404,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **ACCEPTED_USERNAME_AND_AVATAR = 405**  
_Sent when an entered username/avatar are valid_  
```javascript
{
  messageType: 405,
  letterCode: "ABCD" (Added by Networking.gd)
}
```

* **INVALID_PROMPT_RESPONSE = 411**  
_Sent when a prompt response is invalid_  
```javascript
{
  messageType: 411,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123"
}
```

* **ACCEPTED_PROMPT_RESPONSE = 412**  
_Sent when host successfully obtains a player response to a prompt_  
```javascript
{
  messageType: 412,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123"
}
```

* **INVALID_VOTE_RESPONSE = 421**  
_Sent when a vote response is invalid_  
```javascript
{
  messageType: 421,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123"
}
```

* **ACCEPTED_VOTE_RESPONSE = 422**  
_Sent when a vote response is successfully obtained by the host_  
```javascript
{
  messageType: 422,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123"
}
```

* **INVALID_MULTI_VOTE = 431**  
_Sent when a multi vote response is invalid_  
```javascript
{
  messageType: 431,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123"
}
```

* **ACCEPTED_MULTI_VOTE = 432**  
_Sent when a multi vote is successfully obtained by the host_  
```javascript
{
  messageType: 432,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123"
}
```

* **UPDATE_PLAYER_GAME_STATE = 440**  
_Sent when a Player requests to be updated on the current game state_  
```javascript
{
  messageType: 440,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123",
  gameState: 3
}
```

## Messages Sent from Player:
* **PLAYER_CONNECTED = 401**  
_Sent from player to inform of new player connection_  
```javascript
{
  messageType: 401,
  letterCode: "ABCD"
}
```

* **PLAYER_DISCONNECTED = 402**  
_Sent from player to inform of disconnect from server, such as quitting_  
```javascript
{
  messageType: 402,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123"
}
```

* **PLAYER_USERNAME_AND_AVATAR = 403**  
_Sent to update player's username and avatar on the host_  
```javascript
{
  messageType: 403,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123", (Added by GameStateManager.gd)
  username: "username",
  avatarIndex: 1
}
```

* **PLAYER_RECONNECT = 406**  
_Sent when a Player has disconnected and wants to reconnect to an existing host that it was previously connected to_  
```javascript
{
  messageType: 406,
  letterCode: "ABCD",
  playerID: "abc-123"
}
```

* **PLAYER_SENDING_PROMPT_RESPONSE = 410**  
_Sent to deliver an answer to a prompt to the host_  
```javascript
{
  messageType: 410,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123", (Added by GameStateManager.gd)
  promptID: 1,
  emojiArray: [[1,1,40010],[1,3,40020],...]
}
```

* **PLAYER_SENDING_SINGLE_VOTE = 420**  
_Sent to deliver an answer to a vote to the host_  
```javascript
{
  messageType: 420,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123", (Added by GameStateManager.gd)
  voteID: 1
}
```

* **PLAYER_SENDING_MULTI_VOTE = 430**  
_Sent to deliver an answer to the final round to the host_  
```javascript
{
  messageType: 430,
  letterCode: "ABCD", (Added by Networking.gd)
  playerID: "abc-123", (Added by GameStateManager.gd)
  voteArray: [1,2,3]
}
```

## Messages Sent from Server:
* **SERVER_MESSAGE_ERROR = 100**  
_Sent from Server when error parsing_  
```javascript
{
  messageType: 100
}
```

* **SERVER_SENDING_CODE = 111**  
_Sent from Server when first delivering ABCD code_  
```javascript
{
  messageType: 111,
  letterCode: "ABCD"
}
```

* **VALID_SERVER_CODE = 112**  
_Sent from Server when Player enters a valid code_  
```javascript
{
  messageType: 112,
  letterCode: "ABCD",
  playerID: "abc-123",
  isPlayer: true
}
```

* **INVALID_SERVER_CODE = 113**  
_Sent from Server when Player enters an invalid code_  
```javascript
{
  messageType: 113
}
```

* **SERVER_PING = 120**  
_Sent from Server when Server is checking if the game is still active_  
```javascript
{
  messageType: 120
}
```

* **SERVER_FORCE_DISCONNECT_CLIENT = 131**  
_Sent from Server when the Server forces a player to disconnect_  
```javascript
{
  messageType: 131
}
```

* **INVALID_MESSAGE_JSON = 601**  
_Sent from server if message received is invalid JSON_  
```javascript
{
  messageType: 601
}
```


# Message Dictionary Fields

## ALWAYS ADDED TO THE MESSAGE:  
> **messageType**				- The constand value for the type of message being sent to/from the server  
> **letterCode**				- The ABCD code the host should display on screen, generated by the server  

## Other Fields:
**prompt**					- A string message for the prompt to display on the player screens  
**promptArray**				- An array of multiple string prompts to display one after another  
**promptID**				- The ID number of a given prompt, generated by the host  
**emojiArray**				- An array of [emojiID, xCoord, yCoord] representing user emoji placements  
**answers**					- An array of emoji arrays representing user answers  
**playerID**				- The ID number of a given player, generated by the server  
**isPlayer**				- True when the given player is not an audience member but will answers prompts  
**username**				- The string username chosen by a player to represent themselves on the host  
**avatarIndex**				- The ID of the avatar image chosen to represent a player on the host  
**voteID**					- The ID of the answer the player has chosen to vote for  
**voteArray**				- An array of voteIDs that the player has chosen to vote for  
**gameState**       - A number that identifies the current game state
