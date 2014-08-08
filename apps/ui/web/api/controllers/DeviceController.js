/**
 * DeviceController
 *
 * @description :: Server-side logic for managing devices
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
  go: function (req, res) {
    res.view("device", {page: 'Devices'});
  },

  find: function(req, res) {
    BusService.listDevices(function(err, devices) {
      if(err) return res.json({err:"Could not list devices."});
      res.json({devices:devices});
    });
  },

  setstate: function(req, res) {
    var id = req.param('id');
    if(!id) return res.json({err:'No id provided'});

    var state = req.param('state');
    if(!state) return res.json({err:'No state provided'});

    if(['on','off'].indexOf(state) == -1)
        return res.json({err:'Invalid state provided'});

    BusService.setDeviceState(id, state, function(err) {
      if(err) return res.json({err:"Could not set device state."});
      res.json({status:'ok'});
    });
  }
};

