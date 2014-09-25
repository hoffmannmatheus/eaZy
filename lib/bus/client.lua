
--------------------------------------------------------------------------------
-- Class used by the Client entity to communicate to the Server.
--
-- The communication channel should be configured using the three ports:
-- - com_port: Used to receive broadcast messages from the Server entity. 
-- - set_port: Used to send messages/request data to the Server entity.
-- - res_port: Used to receive a responce from a Server.
--------------------------------------------------------------------------------
local bus_client = {}
local zmq  = require('lzmq')
local json = require('json')
local util = require('lib.util.util')
--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------
local HOST     = '127.0.0.1'
local COM_PORT = 5556
local SET_PORT = 5557
local RES_PORT = 5558
--------------------------------------------------------------------------------

--- Creates a new Bus Client instance.
--
-- @param opt An object that contains the configuration for this Bus Client. If
--        not provided, the default configurations will be set.
--        eg: 
--        {id="Me", filter="server" host="localhost", 
--        com_port=1, set_port=2, res_port=3}
-- @return table The new Bus Client instance.
function bus_client:new(opt)
    local self = {}
    setmetatable(self, {__index=bus_client})
    opt = opt or {}
    self.id       = opt.id       or 'client_id'
    self.host     = opt.host     or HOST
    self.com_port = opt.com_port or COM_PORT
    self.set_port = opt.set_port or SET_PORT
    self.res_port = opt.res_port or RES_PORT
    self.filter   = opt.filter   or nil
    return self
end

--- Prepares this Bus Server to be used.
-- Before sending/receiving messages, the method setup() should be called to
-- properly setup the socket configurations.
--
-- @return table The instance itself.
function bus_client:setup()
    self.context = zmq.context()
    self.sub_socket, err = self.context:socket(zmq.SUB)
    zmq.assert(self.sub_socket, err)
    if self.filter then self.sub_socket:subscribe(self.filter) end
    self.sub_socket:connect('tcp://'..self.host..':'..self.com_port)
    return self
end

--- Receives a message from the communication channel's Server
-- Tryies to get a message from the communication channel, checking the
-- 'com_port' for broadcast messages from the Server.
--
-- @param blocking If false, the method will check if there is a message and
--        then retrun the message, if it exists, or 'nil' if no message was
--        received.  If true, the method will block the interpreter until a new
--        message arrives, which then is returned.
-- @return string The message, if exists, or nil, if no message was received.
function bus_client:check_income(blocking)
    local raw_data = self.sub_socket:recv(blocking and nil or zmq.NOBLOCK)
    if not raw_data then return nil end
    local sender, msg = unpack(util.split(raw_data, ' ',true))
    return json.decode(msg), sender
end

--- Send a message to the Server.
-- Send the given message to the Server of this communication channel, using the
-- 'set_port'.
--
-- @param msg A table or string containing the message. 
-- @return table The instance itself.
function bus_client:send(data, type)
    if not data then return end
    local msg = {type=type or 'send', data=data, sender=self.id}
    local set_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(set_socket, err)
    set_socket:connect('tcp://'..self.host..':'..self.set_port)
    set_socket:send(json.encode(msg))
    set_socket:close()
    return self
end

--- Make a request for the Server.
-- When called, a message is sent to the Server indicating this Client has made
-- a request. The Client will stay blocked until the response from the Server is
-- received on the 'res_port', and then returned.
--
-- @param request A string indicating the request (eg. 'device_list')
-- @return table The response from the Server.
function bus_client:get(request)
    if not request then return end
    self:send(request, 'get')
    local res_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(res_socket, err)
    res_socket:bind('tcp://'..self.host..':'..self.res_port)
    local response = res_socket:recv()
    res_socket:close()
    return json.decode(response).data
end

return bus_client
