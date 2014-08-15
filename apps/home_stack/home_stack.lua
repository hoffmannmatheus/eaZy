
--------------------------------------------------------------------------------
-- Home Stack
--
-- Module responsible for interfacing User Interface and Device Controller.
--
-- The objective of Home Stack is to provide a seamless interface to where any
-- UI implementation can access to get user information.
-- Any user preferences, device names and scenes are stored in here.
-- Also, all events trigged by scenes are sent to UI from Home Stack.
--------------------------------------------------------------------------------

local json          = require('json')
local bus_client    = require('lib.bus.client')
local bus_server    = require('lib.bus.server')

local scene_engine  = require('apps.home_stack.scene_engine')
local device_mapper = require('apps.home_stack.device_mapper')

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
    log('Message: sender,type,data', msg.sender, msg.type, msg.data)
    if msg.type == 'get' then 
        local my_response = 'my response to '..msg.data..' is buga.'
        comm:send(my_response, 'response')
    else
        ui:distribute({sender='home_stack', type=msg.type, data=msg.data})
    end
end

local treat_ui_msg = function(msg)
    log('UI Message: ', msg.sender, msg.type, msg.data)
    if msg.type == 'get' then
        if msg.data == 'devicelist' then
            local list = comm:get('devicelist')
            ui:sendResponse(device_mapper.map(list))
        else
            ui:sendResponse('So you want '..msg.data..'?')
        end
    elseif msg.type == 'send' then
        msg.data.id = device_mapper.getRawDeviceId(msg.data.id)
        comm:send(msg.data)
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

