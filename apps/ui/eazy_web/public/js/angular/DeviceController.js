angular.module('eazy_web').controller('DeviceController', function($scope, $http, socket){
  $scope.init = function(){
    console.log('hello from device');
    $http.get('/device/find').
    success(function(data, status, headers, config) {
      console.log(data);
      if(!data.devices) return console.log('oh, no devices found!');
      $scope.devices = [];
      data.devices.forEach(function(d) {
        if(d.consumption_current)
          d.consumption_current = Math.round(d.consumption_current*100)/100;
        if(d.consumption_current)
          d.consumption_accumulated = Math.round(d.consumption_accumulated*100)/100;
        if(d.type == 'thermometer')
          d.value = Math.round(d.value*100)/100;
        $scope.devices.push(d);
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
