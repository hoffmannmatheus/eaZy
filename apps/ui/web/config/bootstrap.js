module.exports.bootstrap = function(cb) {

  BusService.init();
  cb();
};
