
local mock_list = {
    {
    id=12345,
    registration="registered",
    type="appliance",
    name="My Cute Appliace",
    state= "on",
    consumption_current=4.2,
    consumption_accumulated=23.1
    },
    {
    id=1245,
    registration="registered",
    type="appliance",
    name="A Dishwasher",
    state= "off",
    consumption_current=0.2,
    consumption_accumulated=23.1
    },
    {
    id=32145,
    registration="registered",
    type="presencesensor",
    name="Corridor Sensor",
    state= "off"
    },
    {
    id=345,
    registration="registered",
    type="light",
    name="Room Light",
    state= "on",
    consumption_current=2.1,
    consumption_accumulated=19.4
    },
    {
    id=3265,
    registration="registered",
    type="thermometer",
    name="Kitchen Temp",
    state= "on",
    value= 23.6
    }
}


local json       = require('json')
local bus_client = require('lib.bus.client')
local bus_server = require('lib.bus.server')

local comm = bus_client:new({
    id='home_stack',
    filter='device_controller'
})
local ui = bus_server:new({
    id='home_stack',
    com_port=5560,
    set_port=5561,
    res_port=5562
})

local running = true
local log = function(...) print('<:> Home Stack <:>', ...) end

comm:setup()
ui:setup()

local treat_comm_msg = function(msg)
    log('Message: from,type,data', msg.from, msg.type, msg.data)
    if msg.type == 'get' then 
        local my_response = 'my response to '..msg.data..' is buga.'
        comm:send(my_response, 'response')
    else
        ui:distribute({from='home_stack', type=msg.type, data=msg.data})
    end
end

local treat_ui_msg = function(msg)
    log('UI Message: ', msg.from, msg.type, msg.data)
    if msg.type=='get' then
        if msg.data == 'devicelist' then
            ui:sendResponse(json.encode(mock_list));
        else
            ui:sendResponse('So you want '..msg.data..'?');
        end
    else
        ui:distribute({from='home_stack', type=msg.type, data=msg.data})
    end
end

local life_loop = function()
    local msg
    msg = comm:check_income()
    if msg then treat_comm_msg(msg); msg = nil end
    msg = ui:getMessage('noblock')
    if msg then treat_ui_msg(msg) end
end

log('Running ...')
while running do life_loop() end
log('Stopped.')

