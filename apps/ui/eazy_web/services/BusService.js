
var zmq = require('zmq');

var HOST     = '127.0.0.1';
var COM_PORT = 5560;
var SET_PORT = 5561;
var RES_PORT = 5562;

var com_socket;

module.exports = {

  setup: function(io) {
    com_socket = zmq.socket('sub');
    com_socket.connect('tcp://'+HOST+':'+COM_PORT);
    com_socket.subscribe('home_stack');
    com_socket.on('message', function(msg) {
      var msg = msg.toString();
      try { 
          var sender = msg.split(' ',1)[0];
          var evt  = JSON.parse(msg.substr(msg.indexOf(' ')+1));
          console.log(evt);

          if(typeof evt.data == 'object') {
            io.sockets.emit(evt.data.type, evt.data);
          } else {
            console.log('dunno what to do.');
          }
      } catch(e) {
          console.log("Wrong message format. Msg:",msg,"Error:",e);
      }
    });
  },

  sendMessage: function(data, type) {
    var msg = {type:type||'send', data:data||'', sender:'web'};
    var set_socket = zmq.socket('pair');
    set_socket.connect('tcp://'+HOST+':'+SET_PORT);
    console.log('sending', JSON.stringify(msg));
    set_socket.send(JSON.stringify(msg));
    set_socket.close();
  },

  getData: function(data, cb) {
    this.sendMessage(data, 'get');
    var res_socket =  zmq.socket('pair');
    res_socket.bind('tcp://'+HOST+':'+RES_PORT);
    res_socket.on('message', function(response) {
      cb(null, JSON.parse(response.toString()));
      res_socket.close();
    });
  }
};
