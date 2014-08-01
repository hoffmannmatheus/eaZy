/**
 * SettingsController
 *
 * @description :: Server-side logic for managing settings
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
	
  go: function (req, res) {
    res.view("settings", {page: 'Settings'});
  }
};

