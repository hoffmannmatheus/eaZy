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
    BusService.getData('devicelist', function(err, raw_devices) {
      if(err) return res.json({err:"Could not list devices."});
      var devices = [];
      try{devices = JSON.parse(raw_devices);}
      catch(e) {console.log('Parse device list error:',e);}
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

    BusService.sendMessage({action:'setstate',id:id,state:state});
    res.json({status:'ok'});
  }
};

