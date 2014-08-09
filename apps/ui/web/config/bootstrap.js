module.exports.bootstrap = function(cb) {

  BusService.setup();

  cb();
};
