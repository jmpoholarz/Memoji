const net = require('net');
const _ = require('lodash');
const uuid = require('uuid/v1');
const moment = require('moment');
const fs = require('fs');
const cluster = require('cluster');

const port = 3000;

const max_players = 8;
const max_audience = 100;
var mtype = '';

const server_log = 'server_log.txt';
const error_log = 'server_error_log.txt';

const GET_ALL = 'GET_ALL';
const UPDATE_ALL = 'UPDATE_ALL';
const CODES_UPDATE = 'CODES_UPDATE';
const HOSTS_UPDATE = 'HOSTS_UPDATE';
const PLAYERS_UPDATE = 'PLAYERS_UPDATE';
const AUDIENCE_MEMBERS_UPDATE = 'AUDIENCE_MEMBERS_UPDATE';

let codes = [];
let hosts = [];
let players = [];
let audience_members = [];

let curr_process = null;

if (cluster.isMaster) {

  console.log(`Master ${process.pid} is running`);
  const start_time = moment().format('YYYY-MM-DD hh:mm:ss A');
  console.log(`Server start time: ${start_time}`);

  fs.access(server_log, fs.F_OK, (err) => {
    if (err) {
      fs.writeFile(server_log, `[${start_time}]: # Server Start | Beginning of server log\n`, 'utf8', (err) => {
        if (err) throw err;
        console.log('server_log.txt created successfully.');
      });
    } else {
      // Server log already exists.
      // Append to Server Log
      console.log('server_log.txt already exists.');
      fs.appendFile(server_log, '\r\n\r\n', 'utf8', (err) => {
        if (err) throw err;
        console.log(`Appended to file ${server_log}`);
      });
      writeToFile(server_log, '# Server Start | Beginning of server log');
    }
  });

  fs.access(error_log, fs.F_OK, (err) => {
    if (err) {
      fs.writeFile(error_log, `[${start_time}]: # Server Start | Beginning of error log\n`, 'utf8', (err) => {
        if (err) throw err;
        console.log('server_error_log.txt created successfully.');
      });
    } else {
      // Server Error Log already exists.
      // Append to Server Error Log
      console.log('server_error_log.txt already exists.');
      fs.appendFile(error_log, '\r\n\r\n', 'utf8', (err) => {
        if (err) throw err;
        console.log(`Appended to file ${error_log}`);
      });
      writeToFile(error_log, '# Server Start | Beginning of error log');
    }
  });

  let gCodes = [];
  let gHosts = [];
  let gPlayers = [];
  let gAudience_members = [];

  cluster.fork();

  // Handle local and global variables between Master and Worker processes
  cluster.on('message', (worker, msg, handle) => {
    console.log("Message received from worker:");
    console.log(msg);
    if (msg.topic && msg.topic === GET_ALL) {
      for (const id in cluster.workers) {
        cluster.workers[id].send({
          topic: UPDATE_ALL,
          codes: gCodes,
          hosts: gHosts,
          players: gPlayers,
          audience_members: gAudience_members
        });
      }
    }
    if (msg.topic && msg.topic === CODES_UPDATE) {
      gCodes = msg.codes;
    }
    if (msg.topic && msg.topic === HOSTS_UPDATE) {
      gHosts = msg.hosts;
    }
    if (msg.topic && msg.topic === PLAYERS_UPDATE) {
      gPlayers = msg.players;
    }
    if (msg.topic && msg.topic === AUDIENCE_MEMBERS_UPDATE) {
      gAudience_members = msg.audience_members;
    }
  });

  // Restart a worker if it dies (e.i. on an error)
  cluster.on('exit', (worker, code, signal) => {
    console.log('worker %d died (%s). restarting...',
      worker.process.pid, signal || code);
    cluster.fork();
  });

} else {
  // Workers can share any TCP connection

  // Send a ping to each host every 5 minutes to check if the game is still active
  setInterval(() => {
    console.log("Ping Hosts");
    pingHosts();
    console.log("End Ping Hosts");
    console.log("Ping Players");
    pingPlayers();
    console.log("End Ping Players");
  }, 300000);

  const server = net.createServer(socket => {

    console.log('client connected');

    socket.on('end', () => {
      // Client disconnected
      // Find out if this is a host, player, or audience_member
      var sock = undefined;

      // Is this a Host?
      sock = _.find(hosts, (host) => {
        return host.socket === socket;
      });
      if (sock !== undefined) {
        console.log("Client that disconnected was a Host");
        // Handle Host properly
        console.log(`letterCode: ${sock.letterCode}`);
        handleHostDisConn(sock.letterCode);
        return;
      }
      // Not a Host
      // Is this a Player?
      sock = _.find(players, (player) => {
        return player.socket === socket;
      });
      if (sock !== undefined) {
        console.log("Client that disconnected was a Player:");
        console.log(sock);
        console.log(`LetterCode: ${sock.letterCode}`);
        // Handle Player properly
        _.remove(players, sock);
        sock.isActive = false;
        players.push(sock);
        // Find Host for this player
        const host = _.find(hosts, ['code', sock.letterCode]);
        if (host == undefined) {
          console.error(`Issue finding host with letterCode: ${sock.letterCode}`);
          return;
        }
        // Else Send message to Host that a player has disconnected
        // Remove player from Host players array
        _.remove(host.players, sock);
        const res = {
          "messageType": 132,
          "playerID": sock.id
        }
        sendToHost(sock.letterCode, res);
        return;
      }
      // Is this an Audience Member?
      sock = _.find(audience_members, (audience_member) => {
        return audience_member.socket === socket;
      });
      if (sock !== undefined) {
        console.log("Client that disconnected was an Audience");
        // Handle Audience properly

        return;
      }

      console.log('client disconnected');
    });

    socket.on('data', (data) => {
      console.log(data);
      console.log(data.toString());
      console.log(data.length);

      if (data.length <= 4) {
        // console.log('Ignore message. Length too short.');
        return;
      }

      const json = parseData(data);
      if (json === -1) {
        console.error('Error parsing data');
        const res = {
          "messageType": 100
        };
        writeToFile(error_log, 'Error parsing data received. Server needs message to be sent again');
        send(socket, JSON.stringify(res));
        return;
      }
      var message = "";
      try {
        message = JSON.parse(json);
      } catch (err) {
        console.error(err);
        const res = {
          "messageType": 100
        };
        writeToFile(error_log, 'Error parsing json.');
        send(socket, JSON.stringify(res));
        return;
      }

      console.log(message);

      // See what message type (action)
      var letterCode = ""
      try {
        letterCode = message.letterCode;
      } catch (err) {
        console.warn('Message does not contain letterCode');
        console.warn(err);
        const res = {
          "messageType": 100
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
          console.log(host.lastPing);
          host.lastPing = moment().valueOf();
          console.log(host.lastPing);
          update_hosts();
          writeToFile(server_log, `${letterCode} Host still handling games`);
          break;
        case 122:
          console.log('Player is still active');
          const player_index = _.findIndex(players, (p) => {
            return p.code === letterCode;
          });
          players[player_index].isActive = true;
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
              if (id === -1) {
                console.log('Player already connected to host.');
                writeToFile(error_log, `Player has already connected to host. Do not add to host again.`);
              } else {
                writeToFile(server_log, `Player: [${id}] joined Host - ${letterCode}`);
              }
            } else {
              // Host lobby full, join as audience member
              var id = handleAudienceConn(letterCode, socket);
              writeToFile(server_log, `Audience: [${id}] joined Host - ${letterCode}`);
            }
          } else {
            console.error('Invalid code');
            console.error('Did not handle player connection successfully.');
            const res = {
              "messageType": 113
            };
            send(socket, JSON.stringify(res));
            writeToFile(server_log, 'Player could not join. Invalid letter code.');
          }
          break;
        case 402: // Player Disconnecting
          // Remove player from host
          var r = handlePlayerDisConn(letterCode, message.playerID);
          if (r == -1) {
            console.error("Error handling player disconnection.");
            return;
          }
          writeToFile(server_log, `Player disconnecting from host - ${letterCode}`);
          sendToHost(letterCode, message);
          writeToFile(server_log, `Forward Player disconnection to host - ${letterCode}`);
          break;
        case 406: // Player Reconnecting
          if (codeCheck(letterCode)) {
            handlePlayerReConn(letterCode, message, socket);
          } else {
            console.error('Lobby Code does not exist!');
            console.error('Did not handle player reconnection successfully.');
            const res = {
              "messageType": 113
            };
            send(socket, JSON.stringify(res));
            writeToFile(server_log, 'Player could not join. Invalid letter code.');
          }
          break;
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
        case 301: // Host starting game -----> Send to all Players and Audience
        case 302: // Host ending game -------> Send to all Players and Audience
        case 312: // Host sending answers ---> Send to all Players and Audience
          sendToPlayersAndAudience(letterCode, message);
          if (message.messageType === 301) mtype = 'Host starting game.';
          if (message.messageType === 302) mtype = 'Host ending game.';
          if (message.messageType === 312) mtype = 'Host sending answers.';
          writeToFile(server_log, `[MessageType: ${message.messageType} - ${mtype}] Sending to all Players and Audience`);
          break;
        case 404: // Invalid username ----------------> Send to Player
        case 405: // Accepted Username and avatar ----> Send to Player
        case 411: // Invalid prompt response ---------> Send to Player
        case 412: // Accepted prompt response --------> Send to Player
        case 421: // Invalid vote response -----------> Send to Player
        case 422: // Accepted vote response ----------> Send to Player
        case 431: // Invalid multi vote --------------> Send to Player
        case 432: // Accepted multi vote -------------> Send to Player
        case 440: // Update Player game state --------> Send to Player
          sendToPlayer(message);
          if (message.messageType === 404) mtype = 'Invalid username.';
          if (message.messageType === 405) mtype = 'Host starting game.';
          if (message.messageType === 411) mtype = 'Invalid prompt response.';
          if (message.messageType === 412) mtype = 'Accepted prompt response.';
          if (message.messageType === 421) mtype = 'Invalid vote response.';
          if (message.messageType === 422) mtype = 'Accepted vote response.';
          if (message.messageType === 431) mtype = 'Invalid multi vote.';
          if (message.messageType === 432) mtype = 'Accepted multi vote.';
          if (message.messageType === 440) mtype = 'Update Player game state.';
          writeToFile(server_log, `[MessageType: ${message.messageType} - ${mtype}] Sending to Player: ${message.playerID}`);
          break;
        case 403: // Player username and avatar ------> Send to Host
        case 410: // Player sending prompt response --> Send to Host
        case 420: // Player sending single vote ------> Send to Host
        case 430: // Player sending multi vote -------> Send to Host
          sendToHost(letterCode, message);
          if (message.messageType === 403) mtype = 'Player username and avatar.';
          if (message.messageType === 410) mtype = 'Player sending prompt response.';
          if (message.messageType === 420) mtype = 'Player sending single vote.';
          if (message.messageType === 430) mtype = 'Player sending multi vote.';
          writeToFile(server_log, `[MessageType: ${message.messageType} - ${mtype}] Sending to Host - ${letterCode}`);
          break;
        default:
          console.error('Unknown Message Type');
          writeToFile(error_log, '[MessageType]: Unknown MessageType. No action performed.');
      }

    });

    server.on('error', (err) => {

      writeToFile(error_log, 'An error occured: Save local values.');

      writeToFile(error_log, err.name);
      writeToFile(error_log, err.message);
      const res = {
        "messageType": 100
      };
      writeToFile(error_log, 'Error. Send 100 back to server. Requesting message again.');
      send(socket, JSON.stringify(res));
    });
  });

  server.listen(port, () => console.log(`Listening on port ${port}`));
  console.log(`Worker ${process.pid} started`);

  // Send message to Master to get values from variables
  process.send({
    topic: GET_ALL
  });

  // Receive message from Master
  // Populate arrays
  process.on('message', (msg) => {
    writeToFile(server_log, `Receive global arrays from Master process.`);
    console.log("Worker received message from Master:");
    console.log(msg);
    if (msg.topic && msg.topic === UPDATE_ALL) {
      codes = msg.codes;
      hosts = msg.hosts;
      players = msg.players;
      audience_members = msg.audience_members;
      console.log("UDPATE LOCAL VALUES:");
      console.log(codes);
      console.log(hosts);
      console.log(players);
      console.log(audience_members);
    }
  });

  process.on('uncaughtException', (err) => {
    logError(err);
  });

  process.on('SIGINT', () => {
    console.log("Server Shutting down.");
    try {
      const message = 'Server Shutdown.';
      const timestamp = moment().format('YYYY-MM-DD hh:mm:ss A');
      const final_message = `[${timestamp}]: ${message}\n`;
      fs.appendFileSync(server_log, final_message);
    } catch (err) {
      console.error(err);
    }
    process.exit();
  });

  curr_process = process;

}


function logError(err) {
  console.error(`An error occured!\n${err.stack}\n${err.name} | ${err.message}`);
  writeToFile(error_log, 'An error occured!');
  writeToFile(error_log, `Error stack: ${err.stack}`);
  writeToFile(error_log, `Error name: ${err.name}`);
  writeToFile(error_log, `Error message: ${err.message}`);
}


function parseData(data) {
  console.log("PARSING DATA RECEIVED");
  // Convert buffer to string
  var json = JSON.stringify(data);
  // Convert back to JSON
  var copy = "";
  try {
    copy = JSON.parse(json);
  } catch (err) {
    console.error("THERE HAS BEEN AN ERROR PARSING THE DATA RECEIVED.");
    console.warn(err);
    return -1;
  }
  // Check if data has length buffer at the beginning of buffer.
  var message = "";
  // console.log(copy.data);
  if (copy.data[0] == "{".charCodeAt(0) && copy.data[4] == "{".charCodeAt(0)) {
    // Cut off padding
    console.log('CUT PADDING');
    message = copy.data.slice(4);
  } else if (copy.data[0] != "{".charCodeAt(0)) {
    console.log('CUT PADDING');
    message = copy.data.slice(4);
  } else {
    // No padding to cut
    console.log('DO NOT CUT PADDING');
    message = copy.data;
  }
  // Place new message in buffer
  const b = new Buffer.from(message);
  // Return message without padding
  return b.toString();
}


function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}


async function pingHosts() {
  console.log("Send Ping to Host(s)");
  writeToFile(server_log, 'Sending Ping to Host(s).');
  var hosts_to_remove = []
  var hosts_to_remove_during_ping = []
  var hosts_to_remove_after_ping = []
  _.forEach(hosts, (host) => {
    console.log("Send message to host with letter code:");
    console.log(host.code);
    const res = {
      "messageType": 120
    };
    try {
      send(host.socket, JSON.stringify(res));
    } catch (err) {
      logError(err);
      console.error("Socket has been shutdown");
      console.error("Remove host");
      hosts_to_remove_during_ping.push(host);
    }

  });
  // Sleep for 5 seconds to double check if there was a response
  console.log("Wait 5 seconds");
  await sleep(5000);
  console.log("After 5 seconds. Check for Hosts to remove");
  console.log("Remove unresponsive Host(s)");
  writeToFile(server_log, 'Removing unresponsive Host(s)');
  hosts_to_remove_after_ping = _.filter(hosts, (host) => {
    var host_ping = host.lastPing;
    var current_time = moment().valueOf();
    var diff = Math.abs(host_ping - current_time);
    console.log(host_ping);
    console.log(current_time);
    console.log(diff);
    return diff > 6000;
  });
  hosts_to_remove = hosts_to_remove_during_ping.concat(hosts_to_remove_after_ping);
  console.log(hosts_to_remove);
  _.forEach(hosts_to_remove, (host) => {
    _.remove(players, (player) => {
      return player.code == host.code;
    });
    _.remove(audience_members, (audience_member) => {
      return audience_member.code == host.code;
    })
    _.remove(codes, (code) => {
      return code == host.code;
    });
    host.socket.destroy();
    _.remove(hosts, host);
  });
  printAll();
  update_all();
}


async function pingPlayers() {
  console.log("Send Ping to Players");
  writeToFile(server_log, 'Sending Ping to Players.');
  var players_to_remove = []
  var players_to_remove_during_ping = []
  var players_to_remove_after_ping = []
  _.forEach(players, (player) => {
    console.log("Send message to player with letter code:");
    console.log(player.letterCode);
    player.isActive = false;
    const res = {
      "messageType": 120
    };
    try {
      send(player.socket, JSON.stringify(res));
    } catch (err) {
      logError(err);
      console.error("Socket has been shutdown");
      console.error("Remove host");
      players_to_remove_during_ping.push(host);
    }
  });

  console.log("Wait 5 seconds");
  await sleep(5000);
  console.log("After 5 seconds. Check for Players to remove");
  console.log("Remove unresponsive Player(s)");
  writeToFile(server_log, 'Removing unresponsive Player(s)');

  players_to_remove_after_ping = _.filter(players, (player) => {
    return player.isActive == false;
  });
  players_to_remove = players_to_remove_during_ping.concat(players_to_remove_after_ping);

  console.log(players_to_remove);
  _.forEach(players_to_remove, (player) => {
    _.remove(players, player);
  });

  printAll();
  update_all();

}


function printAll() {
  console.log("CODES:");
  console.log(codes);
  console.log("HOSTS:");
  console.log(hosts);
  console.log("PLAYERS:");
  console.log(players);
  console.log("AUDIENCE");
  console.log(audience_members);
}


function writeToFile(filename, message) {
  const timestamp = moment().format('YYYY-MM-DD hh:mm:ss A');
  const final_message = `[${timestamp}]: ${message}\n`;
  fs.appendFile(filename, final_message, 'utf8', (err) => {
    if (err) throw err;
    console.log(`Appended to file ${filename}`);
  });
}


function update_codes() {
  writeToFile(server_log, 'Update Codes');
  curr_process.send({
    topic: CODES_UPDATE,
    codes: codes
  });
}


function update_hosts() {
  writeToFile(server_log, 'Update Hosts');
  curr_process.send({
    topic: HOSTS_UPDATE,
    hosts: hosts
  });
}


function update_players() {
  writeToFile(server_log, 'Update Players');
  curr_process.send({
    topic: PLAYERS_UPDATE,
    players: players
  });
}


function update_audience() {
  writeToFile(server_log, 'Update Audience Members');
  curr_process.send({
    topic: AUDIENCE_MEMBERS_UPDATE,
    audience_members: audience_members
  });
}


function update_all() {
  update_codes();
  update_hosts();
  update_players();
  update_audience();
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
  // Check if host already exists
  var h = _.find(hosts, (host) => {
    return host.socket == socket;
  });
  if (h != undefined) {
    if (h.code != null || h.code != undefined) {
      console.error(`Host already has code: ${h.code}`);
      return;
    }
  }

  const letterCode = generateCode();
  console.log(letterCode);
  var host = {
    code: letterCode,
    socket: socket,
    players: [],
    audience: [],
    lastPing: moment().valueOf()
  };
  hosts.push(host);

  update_codes();
  update_hosts();

  // Send back letter code
  const res = {
    "messageType": 111,
    "letterCode": letterCode
  };
  send(socket, JSON.stringify(res));
}

// TODO: Look for socket being dead

function handleHostDisConn(letterCode) {
  console.log(`Host is shutting down: ${letterCode}`);
  // Find host via matching socket
  // Send force disonnect message to clients connected to host
  var host = _.find(hosts, ['code', letterCode]);
  _.pull(codes, letterCode);
  if(host == undefined) {
    console.error("There is an issue with host disconnection!");
    console.error("Host is undefined");
    return;
  }
  console.log(host);
  console.log('Send players disconnect message.');

  const res = {
    "messageType": 131
  };

  _.forEach(host.players, (player) => {
    console.log(`Send Player: ${player.id} disconnect message.`);
    send(player.socket, JSON.stringify(res));
    writeToFile(server_log, `Send Player: ${player.id} disconnect message.`);
    _.remove(players, player);
  });
  console.log('Players removed from host lobby');
  writeToFile(server_log, 'Players removed from host lobby');

  _.forEach(host.players, (player) => {
    player.socket.end();
    player.socket.destroy();
    if (player.socket.destroyed) {
      console.log(`Player: ${player.id} socket destroyed successfully`);
      writeToFile(server_log, `Player: ${player.id} socket destroyed successfully`);
    } else {
      console.error(`Player: ${player.id} socket destroyed unsuccessfully`);
      writeToFile(error_log, `Player: ${player.id} socket destroyed unsuccessfully`);
    }
  });

  _.forEach(host.audience, (audience) => {
    console.log(`Send Audience: ${audience.id} disconnect message.`);
    send(audience.socket, JSON.stringify(res));
    writeToFile(server_log, `Send Audience: ${audience.id} disconnect message.`);
    _.remove(audience_members, audience);
  });

  console.log('Audience removed from host lobby');
  writeToFile(server_log, 'Audience removed from host lobby');

  _.forEach(host.audience, (audience) => {
    audience.socket.end();
    audience.socket.destroy();
    if (audience.socket.destroyed) {
      console.log(`Audience member: ${audience.id} socket destroyed successfully`);
      writeToFile(server_log, `Audience member: ${audience.id} socket destroyed successfully`);
    } else {
      console.error(`Audience member: ${audience.id} socket destroyed unsuccessfully`);
      writeToFile(error_log, `Audience member: ${audience.id} socket destroyed unsuccessfully`);
    }
  });

  // Send 'disconnect' to host socket once finished
  host.socket.end();

  // Close host socket
  console.log('Destroy Host socket');
  host.socket.destroy();
  if (host.socket.destroyed) {
    console.log('Host socket destroyed successfully.');
    writeToFile(server_log, 'Host socket destroyed successfully.');
  } else {
    console.error('Host socket destroyed unsuccessfully.');
    writeToFile(error_log, 'Host socket destroyed unsuccessfully.');
  }
  _.remove(hosts, host);
  console.log('Host removed from host list');
  writeToFile(server_log, 'Host removed from host list');
  console.log("PRINT HOSTS:");
  console.log(hosts);
  console.log("PRINT CODES:");
  console.log(codes);

  update_all();
}

/*
Player data structure
{
  code: "ABCD"
  socket: socket object
  id: uuid
  isActive: true
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
    id: id,
    isActive: true
  };
  const host = _.find(hosts, ['code', letterCode]);
  // Looks for if player is already connected to host
  const p = _.find(host.players, (p) => {
    return p.socket === socket;
  });
  // Player is already connected to host
  if (p !== undefined) {
    return -1;
  }
  // Player not already connected to host
  // Proceed
  host.players.push(player);
  players.push(player);

  update_hosts();
  update_players();

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
    id: id,
    isActive: true
  };
  host.audience.push(audience);
  audience_members.push(audience);

  update_hosts();
  update_audience();

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

// TODO: Look for socket being dead

function handlePlayerDisConn(letterCode, id) {
  // Remove player from host
  if (!codeCheck(letterCode)) {
    console.log('Did not handle player disconnection successfully.');
    return 0;
  }
  const host = _.find(hosts, ['code', letterCode]);
  if (host === undefined) {
    console.error(`[ERROR]: Could not find Host - ${letterCode}`);
    writeToFile(error_log, `[ERROR]: Could not find Host - ${letterCode}`);
    // return -1;
  }
  const player = _.find(players, ['id', id]);
  if (player === undefined) {
    console.error(`[ERROR]: Could not find Player: ${id}`);
    writeToFile(error_log, `[ERROR]: Could not find Player: ${id}`);
    return -1;
  }
  var removed_player = _.remove(host.players, player);
  if (removed_player !== undefined) {
    console.log(`Removing player: ${player.id} from host: ${letterCode}`);
    writeToFile(server_log, `Removing player: ${player.id} from host: ${letterCode}`);
    console.log('Handled player removal from host successfully.');
    writeToFile(server_log, 'Handled player removal from host successfully.');
  } else {
    console.error(`[ERROR]: Removing player: ${player.id} from host: ${letterCode}`);
    writeToFile(error_log, `[ERROR]: Removing player: ${player.id} from host: ${letterCode}`);
    console.error('Handled player removal from host unsuccessfully.');
    writeToFile(error_log, 'Handled player removal from host unsuccessfully.');
  }
  removed_player = _.remove(players, player);
  if (removed_player !== undefined) {
    console.log(`Removing player: ${player.id} from player list`);
    writeToFile(server_log, `Removing player: ${player.id} from player list`);
    console.log('Handled player removal from player list successfully.');
    writeToFile(server_log, 'Handled player removal from player list successfully.');
  } else {
    console.error(`Removing player: ${player.id} from player list`);
    writeToFile(error_log, `[ERROR]: Removing player: ${player.id} from player list`);
    console.error('Handled player removal from player list unsuccessfully.');
    writeToFile(error_log, 'Handled player removal from player list unsuccessfully.');
  }
  player.socket.end();

  player.socket.destroy();
  if (player.socket.destroyed) {
    console.log(`Player: ${player.id} socket destroyed successfully`);
    writeToFile(server_log, `Player: ${player.id} socket destroyed successfully`);
  } else {
    console.error(`Player: ${player.id} socket destroyed unsuccessfully`);
    writeToFile(error_log, `Player: ${player.id} socket destroyed unsuccessfully`);
  }

  update_hosts();
  update_players();

  return 1;
}


function handlePlayerReConn(letterCode, message, socket) {
  // Code exists
  console.log("Code exists: " + letterCode);
  // Find player in Players array
  const old_player = _.find(players, (p) => {
    return p.id == message.playerID;
  });
  if (old_player === undefined) {
    console.error("Player does not exist.");
    console.error(":(");
    return;
  }
  // Player has been found

  // Find host to reconnect to
  const host = _.find(hosts, ['code', letterCode]);
  // Find player in host's player array
  const player_in_host = _.find(host.players, (p) => {
    return p.id == old_player.id;
  });
  // Player is not in host's player array
  if (player_in_host == undefined) {
    console.error("Player is not in Host's player array");
    return -1;
  }
  // Player is in host's player array
  const reconnected_player = {
    code: letterCode,
    socket: socket,
    id: message.playerID,
    isActive: true
  }
  host.players.remove(player_in_host);
  host.players.push(reconnected_player);
  players.remove(old_player);
  players.push(reconnected_player);

  update_hosts();
  update_players();

  console.log('Handled player reconnection successfully.');
  var res = {
    "messageType": 114,
    "letterCode": letterCode,
    "playerID": message.playerID
  };
  send(socket, JSON.stringify(res));
  res.messageType = 406;
  send(host.socket, JSON.stringify(res));
  console.log("End of Player reconnection");
}


function existInactivePlayers(letterCode) {
  const host = _.find(hosts, ['code', letterCode]);
  if (host == undefined) {
    console.error(`Issue finding host with given letterCode: ${letterCode}`);
    writeToFile(error_log, `Issue finding host with letterCode: ${letterCode}`);
  }
  var player = _.find(host.players, ['isActive', false]);
  if (player == undefined) {
    console.log('All players are active for this game session');
    return 1;
  } else {
    console.error('There is a player that is Not Active');
    return -1;
  }
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
  console.log(`Length of message: ${n}`);
  const buf = toBytesInt32(n);
  // Store length in Buffer
  const buff = new Buffer.from(arr);
  // Store message in Buffer
  const buff2 = new Buffer.from(data.toString());
  // Send length
  console.log(buff);
  try {
    socket.write(buff);
  } catch (err) {
    logError(err);
  }
  // Send message
  console.log(`Message sent: ${buff2.toString()}`);
  try {
    socket.write(buff2);
  } catch (err) {
    logError(err);
  }
}


function toBytesInt32(num) {
  arr = new ArrayBuffer(4);
  view = new DataView(arr);
  view.setUint32(0, num, false);
  return arr;
}


function codeCheck(letterCode) {
  console.log("PRINT CODES");
  console.log(codes);
  if (!codes.includes(letterCode)) {
    console.error('Code does not exist: ' + letterCode);
    return false;
  }
  return true;
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
