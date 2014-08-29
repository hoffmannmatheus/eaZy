app.filter('key_filter', function() {
  return function(device) {
    if(!device) return null;
    var possibleKeys = ['state', 'battery_level', 'consumption_current',
        'consumption_accumulated', 'temperature', 'luminance', 'presence'];
    var keys = [];
    Object.keys(device).forEach(function(k) {
      if(possibleKeys.indexOf(k) > -1) keys.push(k);
    });
    return keys;
  };
});

app.controller('SceneController', function($scope, $http, socket){
  socket.on('message', function(message) {
    console.log('socket.on message:',message);
  });

  var adjustDevices = function(devices) {
    var list = [];
    devices.forEach(function(d) {
      if(d.registration != "unregistered" && d.registration != "missing"
          && d.type != "unknown") {
        list.push(d);
      }
    });
    return list;
  };

  $scope.init = function() {
    $scope.sceneToDelete = {};
    $http.get('/scene/find').
    success(function(data, status, headers, config) {
      console.log(data);
      if(!data.scenes || !data.scenes.length)
        return console.log('oh, no scenes found!');
      $scope.scenes = data.scenes || [];

      $http.get('/device/find').
      success(function(data, status, headers, config) {
        console.log(data);
        if(!data.devices) return console.log('oh, no devices found!');
        var devices = data.devices || [];
        $scope.devices = adjustDevices(devices);
        $scope.scenes.forEach(function(s) {
          $scope.devices.forEach(function(d) {
            if(s.target_device == d.id) s.target_device = d;
            if(s.source_device == d.id) s.source_device = d;
          });
        });

      }).error(function(data, status, headers, config) {});
    }).error(function(data, status, headers, config) {});
  };

  $scope.loadDevices = function() {
    console.log("devices",$scope.devices);
    if($scope.devices && $scope.devices.length > 0) return;
    $http.get('/device/find').
    success(function(data, status, headers, config) {
      console.log(data);
      if(!data.devices) return console.log('oh, no devices found!');
      var devices = data.devices || [];
      $scope.devices = adjustDevices(devices);
    }).
    error(function(data, status, headers, config) {
    });

  };

  $scope.addScene = function(scene) {
    if(!scene) return console.log('Trying to add null scene');
    console.log('adding...',scene);
    // The stack only accepts ids.
    scene.target_device = scene.target_device.id;
    scene.source_device = scene.source_device.id;
    closeCreateSceneModal()
    $http.post('/scene/add', {scene:scene}).
    success(function(data, status, headers, config) {
      if(data.err) console.log(data.err);
      $scope.init();
    }).
    error(function(data, status, headers, config) {
    });
  };

  $scope.setSceneToDelete = function(scene) {
    $scope.sceneToDelete = scene;
  };

  $scope.deleteScene = function(scene) {
    if(!scene) return console.log('Trying to delete null scene');
    closeDeleteSceneModal()
    $http.post('/scene/delete', {scene:scene}).
    success(function(data, status, headers, config) {
      if(data.err) console.log(data.err);
      $scope.init();
    }).
    error(function(data, status, headers, config) {
    });
  };
});
