

const port = 7575;

const net = require('net');

const server = net.createServer( socket => {

  console.log('client connected');

  socket.on('end', () => {
    console.log('client disconnected');
  });

  socket.on('data', (data) => {
    // console.log(data);
    console.log(data.toString());
    console.log(data.toString().length);
    // const buf = new Buffer([0x05, 0x00, 0x00, 0x00, 0x62, 0x75, 0x66, 0x66, 0x65, 0x72, 0x00]);

    // Send length of message first as unsigned 32 bit integer
    // const msglen = (data.toString().length)>>>0;
    // socket.write(data.toString().length);
    // Send message

    const n = data.toString().length;
    const arr = toBytesInt32(n);

    const buff = new Buffer.from(arr);
    console.log(buff);
    const buff2 = new Buffer.from(data.toString());
    console.log(buff2);
    socket.write(buff);
    socket.write(buff2);
  });

  server.on('error', (err) => {
    throw err;
  });
});

function toBytesInt32(num) {
  arr = new ArrayBuffer(4);
  view = new DataView(arr);
  view.setUint32(0, num, false);
  return arr;
}

server.listen(port, '127.0.0.1');
