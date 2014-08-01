/**
 * DeviceController
 *
 * @description :: Server-side logic for managing devices
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
	
  go: function (req, res) {
    res.view("device", {page: 'Device'});
  }
};

