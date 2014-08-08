
module.exports.routes = {

  'get /'         : 'DashboardController.go',

  'get  /device'         : 'DeviceController.go',
  'get  /device/find'    : 'DeviceController.find',
  'post /device/setstate': 'DeviceController.setstate',

  'get /energy'   : 'EnegyController.go',
  'get /scene'    : 'SceneController.go',
  'get /settings' : 'SettingsController.go',

};
