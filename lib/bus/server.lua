
--------------------------------------------------------------------------------
-- Class used by the Server entity to control communication between components.
--
-- The communication channel should be configured using the three ports:
-- - com_port: Used to broadcast message to Client entities. 
-- - set_port: Used by Clients to send messages to the Server entity.
-- - res_port: Used by the Servery entity to respond to a Client request.
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

--- Creates a new Bus Server instance.
--
-- @param opt An object that contains the configuration for this Bus Server. If
--        not provided, the default configurations will be set.  eg: {id="My
--        Server", host="localhost", com_port=1, set_port=2, res_port=3}
-- @return table The new Bus Server instance.
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

--- Prepares this Bus Server to be used.
-- Before sending/receiving messages, the method setup() should be called to
-- properly setup the socket configurations.
--
-- @return table The instance itself.
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

--- Distribute a message to all Clients.
-- When called, the message will be distributed to all Clientes connected in
-- this communication channel, using the 'com_port'.
--
-- @param msg A table containing the message. 
--        eg: {sender="Me", type="hello", data="from server"}
-- @return table The instance itself.
function bus_server:distribute(msg)
    if not msg then return end
    self.pub_socket:send(msg.sender .. ' ' .. json.encode(msg))
    print('distribute:',msg.sender .. ' ' .. json.encode(msg))
    return self
end

--- Receives a message from the communication channel.
-- Tryies to get a message from the communication channel, checking the
-- 'set_port' for new messages.
--
-- @param noblocking If true, the method will check if there is a message and
--        then return the message, if it exists, or 'nil' if no message was
--        received.  If false, the method will block the interpreter until a new
--        message arrives, which then is returned.
-- @return string The message, if exists, or nil, if no message was received.
function bus_server:getMessage(noblocking)
    local msg = self.set_socket:recv(noblocking and zmq.NOBLOCK)
    if not msg then return nil end
    return json.decode(msg)
end

--- Respond to a Client request.
-- When a Client has requested (ie. sent a message with type='get'), it will be
-- wainting for a response through the 'res_port'. This method uses the
-- 'res_port' to respond to a client request directly.
--
-- @param msg A table containing the message.
--        eg: {sender="Me", type="get", data="user_list"}
-- @return table The instance itself.
function bus_server:sendResponse(msg)
    local res_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(res_socket, err)
    res_socket:connect('tcp://'..self.host..':'..self.res_port)
    res_socket:send(json.encode(msg))
    res_socket:close()
    return self
end

return bus_server
