
module.exports = function (socket) {

  // send the new user their name and a list of users
  socket.emit('message', {hey:'hello'});

  // clean up when a user leaves, and broadcast it to other users
  socket.on('disconnect', function () {
    socket.broadcast.emit('user:left', {
      bye: 'bye'
    });
  });
};
