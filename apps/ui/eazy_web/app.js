var express      = require('express');
var engine       = require('ejs-locals');
var path         = require('path');
var favicon      = require('static-favicon');
var logger       = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser   = require('body-parser');
var _            = require('lodash');

var app = express();
var server = require('http').Server(app);

// Bus and Socket.IO setup

var conns = [];
var io = require('socket.io')(server);
io.sockets.on('connection', function(socket){
    conns.push(socket);
    socket.on('disconnect', function() {
        if(conns.length == 1) return conns = [];
        conns = _.remove(conns, function(c) {
            return c.id == socket.id;
        });
    });
});

var onMessage = function(msg) {
    var msg = msg.toString();
    try { 
        var from = msg.split(' ',1)[0];
        var data = JSON.parse(msg.substr(msg.indexOf(' ')+1));
        console.log(data);
        console.log(conns.length);
        if(conns && conns.length > 0) {
            console.log('sending...');
            conns.forEach(function(s){s.emit('message', data);});
        }
    } catch(e) {
        console.log("Wrong message format. Msg:",msg,"Error:",e);
    }
}

zbus = require('./services/BusService.js');
zbus.setup(onMessage);

// view engine setup

app.set('views', path.join(__dirname, 'views'));
app.engine('ejs', engine);
app.set('view engine', 'ejs');
app.use(favicon());
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded());
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// Routes setup

var dashboard = require('./routes/dashboard');
var device    = require('./routes/device');
var energy    = require('./routes/energy');
var scene     = require('./routes/scene');
var settings  = require('./routes/settings');

app.get('*', dashboard);
app.use('/', dashboard);
app.use('/device', device);
app.use('/energy', energy);
app.use('/scene', energy);
app.use('/settings', settings);


/// catch 404 and forwarding to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

/// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});

server.listen(process.env.PORT || 3000);
console.log('Listenning to port',process.env.PORT || 3000);

