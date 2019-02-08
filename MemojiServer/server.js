const net = require('net');
const port = 7575;

var codes = [];
var hosts = [];
var players = [];

/*
Host data structure
{
  code: "ABCD"
  host: socket object
  players: [p1 socket, p2 socket, ...]
}
*/

/*
Player data structure
{
  code: "ABCD"
  player: socket object
}
*/



const server = net.createServer( socket => {

  console.log('client connected');

  socket.on('end', () => {
    console.log('client disconnected');
  });

  socket.on('data', (data) => {
    console.log(data.toString());
    console.log(data.toString().length);

    const message = parseData(data);
    const parsedData = JSON.parse(message);
    console.log(parsedData);

    // See what message type (action)
    switch(parsedData.messageType){
      case 110: // Host requests new room code
        const letterCode = generateCode();
        console.log(letterCode);

        hosts.push({
          code: letterCode,
          host: socket,
          players: []
        });

        // Send back letter code
        const resjson = {
          "messageType": 111,
          "letterCode": letterCode
        };
        const res = JSON.stringify(resjson);
        send(socket, res);
        break;
      default:
        console.log("Unknown action");
    }
    // send(socket, data);
  });

  server.on('error', (err) => {
    throw err;
  });
});

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

function send(s, data) {
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
  s.write(buff);
  // Send message
  s.write(buff2);
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
  do{
    code = "";
    for(var i = 0; i < 4; i++)
      code += possible.charAt(Math.floor(Math.random() * possible.length));
  } while(codes.includes(code));

  codes.push(code);
  return code;
}

server.listen(port, '127.0.0.1');
