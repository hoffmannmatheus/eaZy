var express      = require('express');
var engine       = require('ejs-locals');
var path         = require('path');
var favicon      = require('static-favicon');
var logger       = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser   = require('body-parser');
var socket       = require('./services/socket.js');

var app = express();
var server = require('http').Server(app);
var io = require('socket.io')(server);

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

io.sockets.on('connection', socket);

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

