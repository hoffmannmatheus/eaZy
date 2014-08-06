
module.exports.routes = {

  'get /'         : 'DashboardController.go',

  'get /device'   : 'DeviceController.go',
  'get /energy'   : 'EnegyController.go',
  'get /scene'    : 'SceneController.go',
  'get /settings' : 'SettingsController.go',
};
