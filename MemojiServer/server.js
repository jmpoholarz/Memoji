const net = require('net');
const _ = require('lodash');
const uuid = require('uuid/v1');
const port = 7575;

var codes = [];
var hosts = [];
var players = [];
var audience = [];

const max_players = 8;
const max_audience = 100;

const server = net.createServer(socket => {

  console.log('client connected');

  socket.on('end', () => {
    console.log('client disconnected');
  });

  socket.on('data', (data) => {
    console.log(data.toString());
    console.log(data.toString().length);

    const json = parseData(data);
    if(json === -1){
      console.warn("Error parsing data");
      const res = {
        "messageType": 601,
        "data": data.toString()
      };
      send(socket, JSON.stringify(res));
      return;
    }
    const message = JSON.parse(json);
    console.log(message);

    // See what message type (action)
    try {
      const letterCode = message.letterCode;
    } catch(err) {
      console.warn("Message does not contain letterCode");
      console.warn(err);
      const res = {
        "messageType": 601,
        "message": data.toString()
      };
      send(socket, JSON.stringify(res));
    }

    switch (message.messageType) {
      case 110: // Host requests new room code
        handleHostCodeRequest(socket);
        break;
      case 121: // Host is still handling games
        console.log("Host is still handling games");
        break;
      case 130: // Host shutting down
        handleHostDisConn(letterCode);
        break;
      // Player Codes
      case 401: // Player Connection and Audience connection
        // Check if there is room in the lobby
        if(codeCheck(letterCode)){
          const host = _.find(hosts, ['code', letterCode]);
          if(host.players.length < max_players){
            // Player can join
            handlePlayerConn(letterCode, socket);
          } else {
            // Host lobby full, join as audience member
            handleAudienceConn(letterCode, socket);
          }
        }
        break;
      case 402: // Player Disconnecting
        // Remove player from host
        handlePlayerDisConn(letterCode, socket);
        break;
      default:
        console.log("Default Forward Message");
    }
    console.log("Hosts: ");
    console.log(hosts);
    // console.log("Players: " + players);
    // console.log("Codes: " + codes);

    // Echo Message back
    // send(socket, data);
  });

  server.on('error', (err) => {
    console.log(err);
    throw err;
  });
});

/*
Host data structure
{
  code: "ABCD"
  host: socket object
  players: [p1 uuid, p2 uuid, ...]
  audience: [a1, a2, a3, ...]
}

Player data structure
{
  code: "ABCD"
  player: socket object
  id: uuid
}

Audience data structure
{
  code: "ABCD"
  audience: socket object
  id: uuid
}
*/

function handleHostCodeRequest(socket) {
  console.log("Code 110: Host request a room code");
  const letterCode = generateCode();
  console.log(letterCode);
  hosts.push({
    code: letterCode,
    socket: socket,
    players: [],
    audience: []
  });
  // Send back letter code
  const res = {
    "messageType": 111,
    "letterCode": letterCode
  };
  send(socket, JSON.stringify(res));
}

function handleHostDisConn(letterCode) {
  console.log("Host is shutting down");
  // Find host via matching socket
  // Send force disonnect message to clients connected to host
  const host = _.remove(hosts, ['code', letterCode]);
  const code = _.remove(codes, (c) => { return c === letterCode;});
  console.log(host);
  console.log(code);
  console.log("Send players disconnect message.");
  const res = {
    "messageType": 131
  };
  _.forEach(host.players, (player) => {
    send(player.socket, JSON.stringify(res));
  });
  _.forEach(host.audience, (audience) => {
    send(audience.socket, JSON.stringify(res));
  })
  console.log("Players removed from host lobby");
}

function handlePlayerConn(letterCode, socket) {
  // Check if letter code exists
  if (!codeCheck(letterCode)) {
    // Letter Code does not exist
    console.log("Invalid code");
    console.log("Did not handle player connection successfully.");
    const res = {
      "messageType": 112
    };
    send(socket, JSON.stringify(res));
    return 0;
  }
  // Code exists
  console.log("Code exists: " + letterCode);
  // Add player to host
  const id = uuid();
  const player = {
    code: letterCode,
    socket: socket,
    id: id
  };
  const host = _.find(hosts, ['code', letterCode]);
  host.players.push(player);
  console.log("Handled player connection successfully.");
  console.log("Send id to player.");
  const res = {
    "messageType": 406,
    "id": id
  }
  send(socket, JSON.stringify(res));
  return 1;
}

function handleAudienceConn(letterCode, socket) {
  const id = uuid();
  const host = _.find(hosts, ['code', letterCode]);
  const audience = {
    code: letterCode,
    socket: socket,
    id: id
  };
  host.audience.push(audience);
  audience.push(audience);
  const res = {
    "messageType": 406,
    "id": id
  }
  send(socket, JSON.stringify(res));
}

function handlePlayerDisConn(letterCode, socket) {
  // Remove player from host
  if (!codeCheck(letterCode)) {
    console.log("Did not handle player disconnection successfully.");
    return 0;
  }
  const host = _.find(hosts, ['code', letterCode]);
  const player = _.remove(host.players, ['player', socket]);
  console.log("Removing player: " + player.id);
  console.log("Handled player disconnection successfully.");
  return 1;
}

function codeCheck(code) {
  if (!codes.includes(letterCode)) {
    console.log("Code does not exist: " + letterCode);
    // Send back 112 code : Invalid server codes
    const res = {
      "messageType": 112
    };
    send(socket, JSON.stringify(res));
    return false;
  }
  return true;
}

function parseData(data) {
  // Convert buffer to string
  const json = JSON.stringify(data);
  // Convert back to JSON
  var copy = "";
  try {
    copy = JSON.parse(json);
  } catch (err) {
    console.warn(err);
    return -1;
  }
  // Cut off padding
  const message = copy.data.slice(4);
  // Place new message in buffer
  const b = new Buffer.from(message);
  // Return message without padding
  return b.toString();
}

function send(socket, data) {
  // Convert length to 32bit integer
  const n = data.toString().length;
  const arr = toBytesInt32(n);
  // Store length in Buffer
  const buff = new Buffer.from(arr);
  // console.log(buff);
  // Store message in Buffer
  const buff2 = new Buffer.from(data.toString());
  console.log("Message sent: " + buff2.toString());
  // Send length
  socket.write(buff);
  // Send message
  socket.write(buff2);
}

function toBytesInt32(num) {
  arr = new ArrayBuffer(4);
  view = new DataView(arr);
  view.setUint32(0, num, false);
  return arr;
}

function generateCode() {
  var code = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  do {
    code = "";
    for (var i = 0; i < 4; i++)
      code += possible.charAt(Math.floor(Math.random() * possible.length));
  } while (codes.includes(code));

  codes.push(code);
  return code;
}

// Call last
server.listen(port, '127.0.0.1');
