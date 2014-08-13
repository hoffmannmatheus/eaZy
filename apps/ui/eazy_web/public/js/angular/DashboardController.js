app.controller('DashboardController', function($scope, $http, socket){
  socket.on('message', function(message) {
    console.log('socket.on message:',message);
  });
  socket.on('setstate', function(data) {
    console.log('socket.on update:',data);
    $scope.devices.forEach(function(d) {
      if(d.id == data.id) d.state = data.state;
    });
    $scope.updateDashboard();
  });
  socket.on('setvalue', function(data) {
    console.log('socket.on update:',data);
    $scope.devices.forEach(function(d) {
      if(d.id == data.id) d.value = data.value;
    });
    $scope.updateDashboard();
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
      $scope.avg_temp      = 0;
      $scope.consumption   = 0;
    });
  };

  $scope.updateDashboard = function() {
    var on_appliances = 0;
    var avg_temp      = 0;
    var consumption   = 0;

    $scope.devices.forEach(function(d) {
      if(d.state == 'on' && d.consumption_current) {
          on_appliances += 1;
          consumption += d.consumption_current;
      }
      if(d.type == 'thermometer') {
        avg_temp = d.value;
      }
    });
    $scope.on_appliances = on_appliances;
    $scope.avg_temp      = Math.round(avg_temp * 100) / 100;
    $scope.consumption   = Math.round(consumption * 100) / 100;
  };

});
