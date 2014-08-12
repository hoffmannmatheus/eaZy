var express = require('express');
var router  = express.Router();

router.get('/', function(req, res) {
  res.render("device", {page: 'Devices'});
});

router.get('/find', function(req, res) {
  zbus.getData('devicelist', function(err, raw_devices) {
    if(err) return res.json({err:"Could not list devices."});
    var devices = [];
    try{devices = JSON.parse(raw_devices);}
    catch(e) {console.log('Parse device list error:',e);}
    res.json({devices:devices});
  });
});

router.post('/setstate', function(req, res) {
  var id = req.param('id');
  if(!id) return res.json({err:'No id provided'});

  var state = req.param('state');
  if(!state) return res.json({err:'No state provided'});

  if(['on','off'].indexOf(state) == -1)
      return res.json({err:'Invalid state provided'});

  zbus.sendMessage({action:'setstate',id:id,state:state});
  res.json({status:'ok'});
});

module.exports = router;
