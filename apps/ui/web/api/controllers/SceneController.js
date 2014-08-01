/**
 * SceneController
 *
 * @description :: Server-side logic for managing scenes
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {

  go: function (req, res) {
    res.view("scene", {page: 'Scene'});
  }
};

