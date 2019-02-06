

const port = 7575;

const net = require('net');

const server = net.createServer( socket => {

  console.log('client connected');

  socket.on('end', () => {
    console.log('client disconnected');
  });

  socket.on('data', (data) => {
    console.log(data.toString());
    console.log(data.toString().length);
    // const buf = new Buffer([0x05, 0x00, 0x00, 0x00, 0x62, 0x75, 0x66, 0x66, 0x65, 0x72, 0x00]);

    // Send length of message first as unsigned 32 bit integer
    // socket.write(data.toString().length);
    // Send message
    socket.write(data.toString());
  });

  // socket.pipe(socket); //send back to socket
});

server.on('error', (err) => {
  throw err;
});

server.listen(port, '127.0.0.1');
