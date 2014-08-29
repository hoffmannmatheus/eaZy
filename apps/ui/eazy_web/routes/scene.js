var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('scene', { page: 'Scenes' });
});

router.get('/find', function(req, res) {
  zbus.getData('scenelist', function(err, scenes) {
    if(err) return res.json({err:"Could not list scenes."});
    res.json({scenes:scenes});
  });
});

router.post('/add', function(req, res) {
  var scene = req.param('scene');
  if(!scene) return res.json({err:'No scene provided'});
  if(!scene.target_device || !scene.source_device)
      return res.json({err:'Invalid scene provided'});

  zbus.sendMessage({type:'addscene', data:scene});
  setTimeout(function() {
      res.json({status:'ok'});
  }, 1500);
});

router.post('/delete', function(req, res) {
  var scene = req.param('scene');
  if(!scene ) return res.json({err:'No scene provided'});
  if(!scene.id) return res.json({err:'Invalid scene provided'});

  zbus.sendMessage({type:'deletescene', data:scene});
  setTimeout(function() {
      res.json({status:'ok'});
  }, 1500);
});

module.exports = router;
