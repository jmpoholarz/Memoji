const net = require('net');
const _ = require('lodash');
const uuid = require('uuid/v1');
const port = 7575;

var codes = [];
var hosts = [];
var players = [];
var audience = [];

const max_players = 8;

/*
Host data structure
{
  code: "ABCD"
  host: socket object
  players: [p1 uuid, p2 uuid, ...]
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

const server = net.createServer(socket => {

  console.log('client connected');

  socket.on('end', () => {
    console.log('client disconnected');
  });

  socket.on('data', (data) => {
    console.log(data.toString());
    console.log(data.toString().length);

    const json = parseData(data);
    const message = JSON.parse(json);
    console.log(message);

    // See what message type (action)
    const letterCode = message.letterCode;
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
            // Player cannot join
            // Join as audience member
            const id = uuid();
            audience.push({
              code: letterCode,
              audience: socket,
              id: id
            });
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
    console.log(hosts);
    console.log(players);
    console.log(codes);

    // send(socket, data);
  });

  server.on('error', (err) => {
    console.log(err);
    // throw err;
  });
});

function handleHostCodeRequest(socket) {
  console.log("Code 110: Host request a room code");
  const letterCode = generateCode();
  console.log(letterCode);
  hosts.push({
    code: letterCode,
    host: socket,
    players: []
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
  const res = {
    "messageType": 131
  };
  _.forEach(host.players, (player) => {
    send(player.player, JSON.stringify(res));
  });
  console.log("Removed");
}

function handlePlayerConn(letterCode, socket) {
  // Check if letter code exists
  if (!codeCheck(letterCode)) {
    console.log("Invalid code");
    console.log("Did not handle player connection successfully.");
    const res = {
      "messageType": 406
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
    player: socket,
    id: id
  };
  const host = _.find(hosts, ['code', letterCode]);
  host.players.push(player);
  console.log("Handled player connection successfully.");
  return 1;
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
  const copy = JSON.parse(json);
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

server.listen(port, '127.0.0.1');