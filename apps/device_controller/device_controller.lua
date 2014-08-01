
local bus_client = require('lib.bus.client')
local bus_server = require('lib.bus.server')

local comm = bus_client:new({
    id='device_controller',
    filter='home_stack'
})
local device_interface = bus_server:new({
    id='device_controller',
    com_port=5564,
    set_port=5565,
    res_port=5566
})

local running = true
local log = function(...) print('<:> Device Controller <:>', ...) end

comm:setup()
device_interface:setup()

local treat_comm_msg = function(msg)
    log('Message: from,type,data', msg.from, msg.type, msg.data)
    if msg.type == 'get' then 
        local my_response = 'my response to '..msg.data..' is buga.'
        comm:send(my_response, 'response')
    end
end

local treat_device_interface_msg = function(msg)
    log('Device Interface Message: ', msg.from, msg.type, msg.data)
    ui:distribute({from='device_controller', type=msg.type, data=msg.data})
end

local life_loop = function()
    local msg
    msg = comm:check_income()
    if msg then treat_comm_msg(msg); msg = nil end
    msg = device_interface:getMessage('noblock')
    if msg then treat_device_interface_msg(msg) end
end

log('Running ...')
while running do life_loop() end
log('Stopped.')

