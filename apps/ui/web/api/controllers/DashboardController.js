/**
 * DashboardController
 *
 * @description :: Server-side logic for managing dashboard
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
	
  go: function (req, res) {
    res.view("dashboard", {page: 'Dashboard'});
  }
};

