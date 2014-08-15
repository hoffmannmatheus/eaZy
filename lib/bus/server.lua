
--------------------------------------------------------------------------------
-- Class used by the bus server to control communication between apps
--------------------------------------------------------------------------------
local bus_server = {}
local zmq  = require('lzmq')
local json = require('json')
--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------
local HOST     = '127.0.0.1'
local COM_PORT = 5556
local SET_PORT = 5557 -- clients send to this port
local RES_PORT = 5558 -- clients get on this port
--------------------------------------------------------------------------------

function bus_server:new(opt)
    local self = {}
    setmetatable(self, {__index=bus_server})
    opt = opt or {}
    self.id       = opt.id       or 'server_id'
    self.host     = opt.host     or HOST
    self.com_port = opt.com_port or COM_PORT
    self.set_port = opt.set_port or SET_PORT
    self.res_port = opt.res_port or RES_PORT
    return self
end

function bus_server:setup()
    self.context = zmq.context()

    self.pub_socket, err = self.context:socket(zmq.PUB)
    zmq.assert(self.pub_socket, err)
    self.pub_socket:bind('tcp://'..self.host..':'..self.com_port)

    self.set_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(self.set_socket, err)
    self.set_socket:bind('tcp://'..self.host..':'..self.set_port)

    return self
end

function bus_server:distribute(msg)
    if not msg then return end
    self.pub_socket:send(msg.sender .. ' ' .. json.encode(msg))
    print('distribute:',msg.sender .. ' ' .. json.encode(msg))
    return self
end

function bus_server:getMessage(noblocking)
    local msg = self.set_socket:recv(noblocking and zmq.NOBLOCK)
    if not msg then return nil end
    return json.decode(msg)
end

function bus_server:sendResponse(msg)
    local res_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(res_socket, err)
    res_socket:connect('tcp://'..self.host..':'..self.res_port)
    res_socket:send(json.encode(msg))
    res_socket:close()
    return self
end

return bus_server
