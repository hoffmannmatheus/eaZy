
var mock_list = [
  {
      id:12345,
      registration:'registered',
      type:'appliance',
      name:'My Cute Appliace',
      state: 'on',
      consumption_current:4.2,
      consumption_accumulated:23.1
  },
  {
      id:1245,
      registration:'registered',
      type:'appliance',
      name:'A Dishwasher',
      state: 'off',
      consumption_current:0.2,
      consumption_accumulated:23.1
  },
  {
      id:32145,
      registration:'registered',
      type:'presencesensor',
      name:'Corridor Sensor',
      state: 'off',
  },
  {
      id:345,
      registration:'registered',
      type:'light',
      name:'Room Light',
      state: 'on',
      consumption_current:2.1,
      consumption_accumulated:19.4
  },
  {
      id:3265,
      registration:'registered',
      type:'thermometer',
      name:'Kitchen Temp',
      state: 'on',
      value: 23.6
  }
];

var zmq = require('zmq');
var socket = zmq.socket('sub');

module.exports = {

  init: function() {
    socket.connect('tcp://localhost:5560');
    socket.subscribe('home_stack');
    socket.on('message', function(data){
      console.log('From socket:', data.toString());
    });
  },

  listDevices: function(cb) {
    // TODO access bus api
    cb(null, mock_list);
  },

  setDeviceState: function(id, state, cb) {
    // TODO send to bus api
    cb(null, cb());
  }
};
