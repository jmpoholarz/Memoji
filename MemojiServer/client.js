const net = require('net');

const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const client = new net.Socket();

client.connect(7575, 'localhost', () => {
  console.log("Connected");
  client.write('Hello, server!');
})

client.on('data', (data) => {
  console.log('Received: ' + data);
  // client.end();

  // client.destroy(); // kill client after server's response
});

client.on('end', () => {
  console.log('Connection closed');
})

function searchPrompt() {
  rl.question('Input > ', (input) => {
    if(input == 'exit'){
      return rl.close();
    }
    client.write(input);

    searchPrompt();
  });
}

searchPrompt();
