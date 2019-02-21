const net = require('net');
const _ = require('lodash');
const uuid = require('uuid/v1');
const moment = require('moment');
const fs = require('fs');
const cluster = require('cluster');

const port = 7575;

var codes = [];
var hosts = [];
var players = [];
var audience = [];

const max_players = 8;
const max_audience = 100;
var mtype = '';

const server_log = 'server_log.txt';
const error_log = 'server_error_log.txt';

if (cluster.isMaster) {
  console.log(`Master ${process.pid} is running`);
  const start_time = moment().format('YYYY-MM-DD hh:mm:ss A')
  console.log(`Server start time: ${start_time}`);
  fs.writeFile(server_log, `[${start_time}]: # Beginning of server log\n`, 'utf8', (err) => {
    if (err) throw err;
    console.log('server_log.txt created successfully.');
  });
  fs.writeFile(error_log, `[${start_time}]: # Beginning of error log\n`, 'utf8', (err) => {
    if (err) throw err;
    console.log('server_error_log.txt created successfully.');
  });

  // Send a ping to each host every 5 minutes to check if the game is still active
  setInterval(() => {
    console.log("Send Ping to Host(s)");
    writeToFile(server_log, 'Sending Ping to Host(s).');
    _.forEach(hosts, (host) => {
      const res = {
        "messageType": 120
      };
      send(host.socket, JSON.stringify(res));
    });
  }, 300000);
  // Check every 5:30 minutes for lastPing > 30000. Remove host if true.
  setInterval(() => {
    console.log("Remove unresponsive Host(s)");
    writeToFile(server_log, 'Removing unresponsive Host(s)');
    var hosts_to_remove = _.filter(hosts, (host) => {
      return (abs(host.lastPing - moment().valueOf()) > 30000);
    });
    _.forEach(hosts_to_remove, (host) => {
      host.socket.destroy();
      _.remove(hosts, host);
    });
  }, 330000);

  // Start workers and listen for messages
  const numCPUs = require('os').cpus().length;
  for (var i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  // Restart a worker if it dies (e.i. on an error)
  cluster.on('exit', (worker, code, signal) => {
    console.log('worker %d died (%s). restarting...',
                  worker.process.pid, signal || code);
    cluster.fork();
  });

} else {
  // Workers can share any TCP connection

  const server = net.createServer(socket => {

    console.log('client connected');

    socket.on('end', () => {
      console.log('client disconnected');
      socket.destroy();
      if(socket.destroyed){
        console.log('Socket destroyed on disconnect successfully.');
        writeToFile(server_log, 'Socket destroyed on disconnect successfully.');
      } else {
        console.log('Socket not destroyed on disconnect successfully.');
        writeToFile(error_log, 'Socket not destroyed on disconnect successfully.');
      }
    });

    socket.on('data', (data) => {
      console.log(data.toString());
      console.log(data.toString().length);

      const json = parseData(data);
      if (json === -1) {
        console.warn('Error parsing data');
        const res = {
          "messageType": 100
        };
        writeToFile(error_log, 'Error parsing data received. Server needs message to be sent again');
        send(socket, JSON.stringify(res));
        return;
      }
      const message = JSON.parse(json);
      console.log(message);

      // See what message type (action)
      var letterCode = ""
      try {
        letterCode = message.letterCode;
      } catch (err) {
        console.warn('Message does not contain letterCode');
        console.warn(err);
        const res = {
          "messageType": 100,
          "message": data.toString()
        };
        writeToFile(error_log, 'Message does not contain letterCode');
        send(socket, JSON.stringify(res));
        return;
      }

      switch (message.messageType) {
        case 110: // Host requests new room code
          handleHostCodeRequest(socket);
          writeToFile(server_log, 'Host requested code');
          break;
        case 121: // Host is still handling games
          console.log('Host is still handling games');
          const host = _.find(hosts, ['code', letterCode]);
          host.lastPing = moment().valueOf();
          writeToFile(server_log, `${letterCode} Host still handling games`);
          break;
        case 130: // Host shutting down
          handleHostDisConn(letterCode);
          break;
          // Player Codes
        case 401: // Player Connection and Audience connection
          // Check if there is room in the lobby
          if (codeCheck(letterCode)) {
            const host = _.find(hosts, ['code', letterCode]);
            if (host.players.length < max_players) {
              // Player can join
              var id = handlePlayerConn(letterCode, socket);
              writeToFile(server_log, `Player: [${id}] joined Host - ${letterCode}`);
            } else {
              // Host lobby full, join as audience member
              var id = handleAudienceConn(letterCode, socket);
              writeToFile(server_log, `Audience: [${id}] joined Host - ${letterCode}`);
            }
          } else {
            console.log('Invalid code');
            console.log('Did not handle player connection successfully.');
            const res = {
              "messageType": 113
            };
            send(socket, JSON.stringify(res));
            writeToFile(server_log, 'Player could not join. Invalid letter code.');
          }
          break;
        case 402: // Player Disconnecting
          // Remove player from host
          handlePlayerDisConn(letterCode, socket);
          writeToFile(server_log, `Player disconnecting from host - ${letterCode}`);
          break;
        case 301: // Host starting game -----> Send to all Players
        case 302: // Host ending game -------> Send to all Players
        case 320: // Host round time is up --> Send to all Players
          sendToAllPlayers(letterCode, message);
          if (message.messageType === 301) mtype = 'Host starting game.';
          if (message.messageType === 302) mtype = 'Host ending game.';
          if (message.messageType === 320) mtype = 'Round timer is over.';
          writeToFile(server_log, `[MessageType: ${message.messageType} - ${mtype}] Sending to all Players`);
          break;
        case 311: // Host Sending promtpt ---> Send to Player
          sendToPlayer(message);
          writeToFile(server_log, `[MessageType: ${message.messageType} - Host sending prompt.] Sending to Player: ${message.playerID}`);
          break;
        case 312: // Host sending answers ---> Send to all Players and Audience
          sendToPlayersAndAudience(letterCode, message);
          writeToFile(server_log, `[MessageType: ${message.messageType} - Host sending answers.] Sending to all Players and Audience`);
          break;
        case 404: // Invalid username ----------------> Send to Player
        case 405: // Accepted Username and avatar ----> Send to Player
          sendToPlayer(message);
          if (message.messageType === 404) mtype = 'Invalid username.';
          if (message.messageType === 405) mtype = 'Host starting game.';
          writeToFile(server_log, `[MessageType: ${message.messageType} - ${mtype}] Sending to Player: ${message.playerID}`);
          break;
        case 403: // Player username and avatar ------> Send to Host
        case 410: // Player sending prompt response --> Send to Host
        case 411: // Invalid prompt response --------> Send to Host
        case 412: // Accepted prompt response --------> Send to Host
        case 420: // Player sending single vote ------> Send to Host
        case 421: // Invalid vote response -----------> Send to Host
        case 422: // Accepted vote response ----------> Send to Host
        case 430: // Player sending multi vote -------> Send to Host
        case 431: // Invalid multi vote --------------> Send to Host
        case 432: // Accepted multi vote -------------> Send to Host
          sendToHost(letterCode, message);
          if (message.messageType === 403) mtype = 'Player username and avatar.';
          if (message.messageType === 410) mtype = 'Player sending prompt response.';
          if (message.messageType === 411) mtype = 'Invalid prompt response.';
          if (message.messageType === 412) mtype = 'Accepted prompt response.';
          if (message.messageType === 420) mtype = 'Player sending single vote.';
          if (message.messageType === 421) mtype = 'Invalid vote response.';
          if (message.messageType === 422) mtype = 'Accepted vote response.';
          if (message.messageType === 430) mtype = 'Player sending multi vote.';
          if (message.messageType === 431) mtype = 'Invalid multi vote.';
          if (message.messageType === 432) mtype = 'Accepted multi vote.';
          writeToFile(server_log, `[MessageType: ${message.messageType} - ${mtype}] Sending to Host - ${letterCode}`);
          break;
        default:
          console.log('Unknown Message Type');
          writeToFile(error_log, '[MessageType]: Unknown MessageType. No action performed.');
      }
      console.log("Hosts: ");
      console.log(hosts);

      // Echo Message back
      // send(socket, data);
    });

    server.on('error', (err) => {
      writeToFile(error_log, err.name);
      writeToFile(error_log, err.message);
      const res = {
        "messageType": 100
      };
      writeToFile(error_log, 'Error. Send 100 back to server. Requesting message again.');
      send(socket, JSON.stringify(res));
      throw err;
    });
  });

  server.listen(port, '127.0.0.1');
  console.log(`Worker ${process.pid} started`);
}

function writeToFile(filename, message) {
  const timestamp = moment().format('YYYY-MM-DD hh:mm:ss A');
  const final_message = `[${timestamp}]: ${message}\n`;
  fs.appendFile(filename, final_message, 'utf8', (err) => {
    if (err) throw err;
    console.log(`Appended to file ${filename}`);
  });
}

/*
Host data structure
{
  code: "ABCD"
  host: socket object
  players: [p1 uuid, p2 uuid, ...]
  audience: [a1, a2, a3, ...]
  lastPing: timestamp
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
    audience: [],
    lastPing: moment().valueOf()
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
  const code = _.remove(codes, (c) => {
    return c === letterCode;
  });
  // Close host socket
  host.destroy();
  console.log(host);
  console.log(code);
  console.log('Send players disconnect message.');
  const res = {
    "messageType": 131
  };
  _.forEach(host.players, (player) => {
    send(player.socket, JSON.stringify(res));
    player.socket.destroy();
  });
  _.forEach(host.audience, (audience) => {
    send(audience.socket, JSON.stringify(res));
    player.socket.destroy();
  })
  console.log('Players removed from host lobby');
}

/*
Player data structure
{
  code: "ABCD"
  player: socket object
  id: uuid
}
*/

function handlePlayerConn(letterCode, socket) {
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
  console.log('Handled player connection successfully.');
  console.log('Send id to player.');
  var res = {
    "messageType": 112,
    "letterCode": letterCode,
    "playerID": id,
    "isPlayer": true
  };
  send(socket, JSON.stringify(res));
  res.messageType = 401;
  send(host.socket, JSON.stringify(res));
  return id;
}

/*
Audience data structure
{
  code: "ABCD"
  audience: socket object
  id: uuid
}
*/

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
  var res = {
    "messageType": 112,
    "letterCode": letterCode,
    "playerID": id,
    "isPlayer": false
  };
  send(socket, JSON.stringify(res));
  res.messageType = 401;
  send(host.socket, JSON.stringify(res));
  return id;
}

function handlePlayerDisConn(letterCode, socket) {
  // Remove player from host
  if (!codeCheck(letterCode)) {
    console.log('Did not handle player disconnection successfully.');
    return 0;
  }
  const host = _.find(hosts, ['code', letterCode]);
  const player = _.remove(host.players, ['player', socket]);
  console.log('Removing player: ' + player.id);
  console.log('Handled player disconnection successfully.');
  player.socket.destroy();
  return 1;
}

function sendToAllPlayers(letterCode, message) {
  const host = _.find(hosts, ['code', letterCode]);
  _.forEach(host.players, (player) => {
    send(player.socket, JSON.stringify(message));
  });
}

function sendToPlayer(message) {
  const player = _.find(players, ['id', message.playerID]);
  send(player.socket, JSON.stringify(message));
}

function sendToPlayersAndAudience(letterCode, message) {
  const host = _.find(hosts, ['code', letterCode]);
  _.forEach(host.players, (player) => {
    send(player.socket, JSON.stringify(message));
  });
  _.forEach(host.audience, (audience) => {
    send(audience.socket, JSON.stringify(message));
  });
}

function sendToHost(letterCode, message) {
  const host = _.find(hosts, ['code', letterCode]);
  send(host.socket, JSON.stringify(message));
}


function send(socket, data) {
  // Convert length to 32bit integer
  const n = data.toString().length;
  const arr = toBytesInt32(n);
  // Store length in Buffer
  const buff = new Buffer.from(arr);
  console.log(buff);
  // Store message in Buffer
  const buff2 = new Buffer.from(data.toString());
  console.log('Message sent: ' + buff2.toString());
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

function codeCheck(letterCode) {
  if (!codes.includes(letterCode)) {
    console.log('Code does not exist: ' + letterCode);
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
