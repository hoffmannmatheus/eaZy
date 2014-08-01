/**
 * UpdateController
 *
 * @description :: Server-side logic for managing updates
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
	
  go: function (req, res) {
    res.view("update", {page: 'Update'});
  }
};

