app.controller('DeviceController', function($scope, $http, socket){
  socket.on('message', function(message) {
    console.log('socket.on message:',message);
  });

  var fixDeviceValues = function(dev) {
    if(dev.consumption_current) {
      if(dev.state == 'off') {
        dev.consumption_current = 0;
      } else {
        dev.consumption_current = Math.round(dev.consumption_current*100)/100;
      }
    }
    if(dev.consumption_accumulated) {
      dev.consumption_accumulated = Math.round(dev.consumption_accumulated*100)/100;
    }
    if(dev.temperature) {
      var temperature = ((dev.temperature - 32) * 5) / 9; // F to C
      dev.temperature = Math.round(temperature*100)/100;
    }
    if(dev.luminance) {
      dev.luminance = Math.round(dev.luminance*100)/100;
    }
    return dev
  }

  socket.on('update', function(evt) {
   for(var i = 0; i < $scope.devices.length; i++) {
      if($scope.devices[i].id == evt.id) {
        $scope.devices[i] = fixDeviceValues(evt.data);
        if(evt.data.type == 'sensor' && evt.data.presence == 'detected') {
          $scope.move_message = evt.data.name+': movement!';
          angular.element('#move-modal-btn').click()
        }
      }
    }
  });

  $scope.init = function() {
    $http.get('/device/find').
    success(function(data, status, headers, config) {
      console.log(data);
      if(!data.devices) return console.log('oh, no devices found!');
      $scope.devices = data.devices || [];
      $scope.devices.forEach(function(d) {
        d = fixDeviceValues(d);
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
