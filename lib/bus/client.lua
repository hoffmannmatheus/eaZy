
--------------------------------------------------------------------------------
-- Class used by any client of a bus-like architecture peer to get/send data
--------------------------------------------------------------------------------
local bus_client = {}
local zmq = require('lzmq')
--------------------------------------------------------------------------------
-- Default Configuration
--------------------------------------------------------------------------------
local HOST      = '127.0.0.1'
local SUB_PORT  = 5556
local SEND_PORT = 5557
local GET_PORT  = 5558
--------------------------------------------------------------------------------

function bus_client:new(opt)
    local self = {}
    setmetatable(self, {__index=bus_client})
    opt = opt or {}
    self.config = {}
    self.config.host      = opt.host      or HOST
    self.config.sub_port  = opt.sub_port  or SUB_PORT
    self.config.send_port = opt.send_port or SEND_PORT
    self.config.get_port  = opt.get_port  or GET_PORT
    self.config.filter    = opt.filter    or nil
    return self
end

function bus_client:setup()
    self.context = zmq.context()
    self.sub_socket, err = self.context:socket(zmq.SUB)
    zmq.assert(self.sub_socket, err)
    if self.config.filter then
        self.sub_socket:subscribe(self.config.filter)
    end
    self.sub_socket:connect('tcp://'..HOST..':'..SUB_PORT)
    return self
end

function bus_client:check_income(blocking)
    local msg = self.sub_socket:recv(blocking and nil or zmq.NOBLOCK)
    return msg
end

function bus_client:send(msg)
    if not msg then return end
    local pair_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(pair_socket, err)
    pair_socket:connect('tcp://'..HOST..':'..SEND_PORT)
    pair_socket:send(msg)
    pair_socket:close()
    return self
end

function bus_client:get(request)
    if not request then return end
    self:send('get:'..request)
    local pair_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(pair_socket, err)
    pair_socket:bind('tcp://'..HOST..':'..GET_PORT)
    local msg = pair_socket:recv() -- it could stop here...
    pair_socket:close()
    return response
end

return bus_client
