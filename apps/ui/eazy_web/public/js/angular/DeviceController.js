app.controller('DeviceController', function($scope, $http, socket){
  socket.on('message', function(message) {
    console.log('socket.on message:',message);
  });
  socket.on('setstate', function(data) {
    console.log('socket.on update:',data);
    $scope.devices.forEach(function(d) {
      if(d.id == data.id) d.state = data.state;
    });
  });
  socket.on('setvalue', function(data) {
    console.log('socket.on update:',data);
    $scope.devices.forEach(function(d) {
      if(d.id == data.id) d.value = data.value;
    });
  });
  socket.on('setconsumption_current', function(data) {
    console.log('socket.on update:',data);
    $scope.devices.forEach(function(d) {
      if(d.id == data.id)
        d.consumption_current = Math.round(data.consumption_current*100)/100;
    });
  });
  socket.on('setconsumption_accumulated', function(data) {
    console.log('socket.on update:',data);
    $scope.devices.forEach(function(d) {
      if(d.id == data.id)
        d.consumption_accumulated = Math.round(data.consumption_accumulated*100)/100;
    });
  });

  $scope.init = function(){
    console.log('hello from device');
    $http.get('/device/find').
    success(function(data, status, headers, config) {
      console.log(data);
      if(!data.devices) return console.log('oh, no devices found!');
      $scope.devices = data.devices;
      $scope.devices.forEach(function(d) {
        if(d.consumption_current)
          d.consumption_current = Math.round(d.consumption_current*100)/100;
        if(d.consumption_current)
          d.consumption_accumulated = Math.round(d.consumption_accumulated*100)/100;
        if(d.temperature) {
          var temperature = ((d.temperature - 32) * 5) / 9; // F to C
          d.temperature = Math.round(temperature*100)/100;
        }
        if(d.luminance)
          d.luminance = Math.round(d.luminance*100)/100;
      });
    }).
    error(function(data, status, headers, config) {
    });
  };

  $scope.changestate = function(device) {
    if(!device) return console.log('oh, no device given.');
    if(!device.state) return console.log('No state to change.');
    if(device.type == 'thermometer' || device.type == 'presencesensor')
      return console.log('Cannot set state to sensors.');

    device.state = device.state == 'on' && 'off' || 'on';
    $http.post('/device/setstate', {id:device.id, state:device.state}).
    success(function(data, status, headers, config) {
      if(data.err) return console.log(data.err);
      $scope.devices.forEach(function(d) {
        if(d.id==device.id) {
          d.state = device.state;
        }
      });
    }).
    error(function(data, status, headers, config) {
    });
  };
});
