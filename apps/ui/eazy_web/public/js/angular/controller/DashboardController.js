angular.module('eazy_web').controller('DashboardController', function($scope, $http, socket){

  socket.on('message', function(message) {
    console.log('socket.on message:',message);
  });

  socket.on('update', function(data) {
    console.log('socket.on update:',data);
  });

  $scope.init = function() {

    $http.get('/device/find').
    success(function(data, status, headers, config) {
      console.log(data);
      $scope.devices = data.devices;

      var on_appliances = 0;
      var avg_temp      = 0;
      var consumption   = 0;

      $scope.devices.forEach(function(d) {
        //if(d.registration == 'registered') {
          if(d.state == 'on' && d.consumption_current) {
              on_appliances += 1;
              consumption += d.consumption_current;
          }
          if(d.type == 'thermometer') {
            avg_temp = d.value;
          }
        //}
      });

      $scope.on_appliances = on_appliances;
      $scope.avg_temp      = Math.round(avg_temp * 100) / 100;
      $scope.consumption   = Math.round(consumption * 100) / 100;
    }).
    error(function(data, status, headers, config) {
      $scope.on_appliances = 0;
      $scope.avg_temp      = 0;
      $scope.consumption   = 0;
    });
  };
});
