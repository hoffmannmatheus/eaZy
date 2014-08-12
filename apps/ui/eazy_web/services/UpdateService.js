
var clients = [];

module.exports = {

  //setup: function() {
    //var server = [];//sails.hooks.http.server;
    //var io = require('socket.io')(server);
    //io.on('connection', function(socket) {
      //console.log('io: new connection:');
      //clients.push(socket);
      //socket.on('disconnect', function() {
        //console.log('io: disconnected', socket);
      //});
    //});
    //io.listen(server);
  //},

  addClient: function(socket){
    clients.push(socket);
    console.log('sending msg');
    socket.emit('messsage', {yay:'welcome'});
  },
  
  handle: function(data) {
    console.log('handle: ', data);
    if(!data || !data.action)
      return console.log('Dont know what to do for:', data);
    switch(data.action) {
      case 'setstate':
        send(data);
        break;
      case 'newdevice':
        send(data);
        break;
    };
  }
};
