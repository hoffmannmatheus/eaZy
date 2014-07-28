
--------------------------------------------------------------------------------
-- Class used by any client of a bus-like architecture peer to get/send data
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

function bus_client:setup()
    self.context = zmq.context()
    self.sub_socket, err = self.context:socket(zmq.SUB)
    zmq.assert(self.sub_socket, err)
    if self.filter then self.sub_socket:subscribe(self.filter) end
    self.sub_socket:connect('tcp://'..self.host..':'..self.com_port)
    return self
end

function bus_client:check_income(blocking)
    local raw_data = self.sub_socket:recv(blocking and nil or zmq.NOBLOCK)
    if not raw_data then return nil end
    local from, msg = unpack(util.split(raw_data, ' '))
    return json.decode(msg), from
end

function bus_client:send(data, type)
    if not data then return end
    local msg = {type=type or 'send', data=data, from=self.id}
    local set_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(set_socket, err)
    set_socket:connect('tcp://'..self.host..':'..self.set_port)
    set_socket:send(json.encode(msg))
    set_socket:close()
    return self
end

function bus_client:get(request)
    if not request then return end
    self:send(request, 'get')
    local res_socket, err = self.context:socket(zmq.PAIR)
    zmq.assert(res_socket, err)
    res_socket:bind('tcp://'..self.host..':'..self.res_port)
    local response = res_socket:recv() -- it could stop here...
    res_socket:close()
    return json.decode(response).data
end

return bus_client
