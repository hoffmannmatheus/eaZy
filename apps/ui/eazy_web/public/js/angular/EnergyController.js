app.controller('EnergyController', function($scope, $http, socket){
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
          $scope.move_message = (evt.data.name || evt.data.product_name)
              + ': movement!';
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
      $scope.overalConsumption = 0;
      $scope.devices.forEach(function(d) {
        d = fixDeviceValues(d);
        if(d.consumption_accumulated > 0) {
          $scope.overalConsumption += d.consumption_accumulated;
        }
      });
    }).
    error(function(data, status, headers, config) {
    });
  };
});
