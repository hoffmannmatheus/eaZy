var express = require('express');
var router  = express.Router();

router.get('/', function(req, res) {
  res.render("device", {page: 'Devices'});
});

router.get('/find', function(req, res) {
  zbus.getData('devicelist', function(err, devices) {
    if(err) return res.json({err:"Could not list devices."});
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

  zbus.sendMessage({type:'setstate',id:id,state:state});
  res.json({status:'ok'});
});

router.post('/update', function(req, res) {
  var device = req.param('device');
  if(!device) return res.json({err:'No device provided'});

  zbus.sendMessage({type:'update', data:device});
  setTimeout(function() {
      res.json({status:'ok'});
  }, 1500);
});

router.post('/delete', function(req, res) {
  var device = req.param('device');
  if(!device) return res.json({err:'No device provided'});

  zbus.sendMessage({type:'delete', data:device});
  setTimeout(function() {
      res.json({status:'ok'});
  }, 1500);
});

module.exports = router;
