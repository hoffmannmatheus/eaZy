
var zmq = require('zmq');

var HOST     = '127.0.0.1';
var COM_PORT = 5560;
var SET_PORT = 5561;
var RES_PORT = 5562;

var com_socket;

module.exports = {

  setup: function(onMessage) {
    com_socket = zmq.socket('sub');
    com_socket.connect('tcp://'+HOST+':'+COM_PORT);
    com_socket.subscribe('home_stack');
    com_socket.on('message', onMessage);
  },

  sendMessage: function(data, type) {
    var msg = {type:type||'send', data:data||'', from:'web'};
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
