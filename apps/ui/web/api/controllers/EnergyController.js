/**
 * EnergyController
 *
 * @description :: Server-side logic for managing energy
 * @help        :: See http://links.sailsjs.org/docs/controllers
 */

module.exports = {
	
  go: function (req, res) {
    res.view("energy", {page: 'Energy'});
  }
};

