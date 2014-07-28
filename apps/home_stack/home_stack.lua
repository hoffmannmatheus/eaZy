
local bus_client = require('lib.bus.client')

local comm = bus_client:new({
    id='home_stack',
    filter='test_stack'
})
local ui = bus_client:new({
    id='home_stack',
    filter='ui_stack',
    sub_port=5560,
    send_port=5561,
    get_port=5562
})

local running = true
local log = function(...) print('<:> Home Stack <:>', ...) end

comm:setup();
ui:setup();

local treat_comm_msg = function(msg)
    log('Message: from,type,data', msg.from, msg.type, msg.data)
    if msg.type == 'get' then 
        local my_response = 'my response to '..msg.data..' is buga.'
        comm:send(my_response, 'response')
    end
end

local treat_ui_msg = function(msg)
    log('testing get');
    local response = comm:get('deviceList')
end

local life_loop = function()
    local msg
    msg = comm:check_income()
    if msg then treat_comm_msg(msg); msg = nil end
    msg = ui:check_income()
    if msg then treat_ui_msg(msg) end
end

log('Running ...')
while running do life_loop() end
log('Stopped.')

