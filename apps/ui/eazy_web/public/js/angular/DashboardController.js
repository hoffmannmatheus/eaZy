app.controller('DashboardController', function($scope, $http, socket){
  socket.on('message', function(message) {
    console.log('socket.on message:',message);
  });

  socket.on('update', function(evt) {
    console.log('socket.on update:', evt);
    for(var i = 0; i < $scope.devices.length; i++) {
      if($scope.devices[i].id == evt.id) {
        $scope.devices[i] = evt.data;
      }
    }
    $scope.updateDashboard();
  });

  $scope.init = function() {
    $scope.devices = [];
    $http.get('/device/find').
    success(function(data, status, headers, config) {
      console.log(data);
      $scope.devices = data.devices;
      $scope.updateDashboard();
    }).
    error(function(data, status, headers, config) {
      $scope.on_appliances = 0;
      $scope.temperature   = 0;
      $scope.luminance     = 0;
      $scope.consumption   = 0;
    });
  };

  $scope.updateDashboard = function() {
    var on_appliances = 0;
    var temperature   = 0;
    var consumption   = 0;
    var luminance     = 0;
    $scope.devices.forEach(function(d) {
      if(d.state == 'on' && d.type == 'appliance') {
          on_appliances += 1;
          consumption += d.consumption_current;
      }
      if(d.type == 'sensor') {
        if(d.temperature) {
            temperature = ((d.temperature - 32) * 5) / 9; // F to C
        } else {
            temperature = 0;
        }

        luminance   = d.luminance || 0;
      }
    });
    $scope.on_appliances = on_appliances;
    $scope.temperature   = Math.round(temperature * 100) / 100;
    $scope.luminance     = Math.round(luminance * 100) / 100;
    $scope.consumption   = Math.round(consumption * 100) / 100;
  };

});
