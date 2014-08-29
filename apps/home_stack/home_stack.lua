
--------------------------------------------------------------------------------
-- Home Stack
--
-- Module responsible for interfacing User Interface and Device Controller.
--
-- The objective of Home Stack is to provide a seamless interface through where
-- any UI implementation can access (using Zero MQ) to get user information.
-- Any user preferences, device names and scenes are stored in here.
-- Also, all events trigged by scenes are sent to UI from Home Stack.
--------------------------------------------------------------------------------

local json          = require('json')
local bus_server    = require('lib.bus.server')

local scene_engine  = require('apps.home_stack.scene_engine')
local device_mapper = require('apps.home_stack.device_mapper')
local db            = require('apps.home_stack.data.db')

--------------------------------------------------------------------------------
-- Local functions
--------------------------------------------------------------------------------

local lifeLoop
local onUIMessage
local onDeviceMessage
local getDeviceResponse
local log = function(...) print('<:> Home Stack <:>', ...) end

--------------------------------------------------------------------------------
-- Setup
--------------------------------------------------------------------------------

local device = bus_server:new({
    id     = 'home_stack',
    filter = 'device_controller'
})
local ui = bus_server:new({
    id       = 'home_stack',
    com_port = 5560,
    set_port = 5561,
    res_port = 5562
})

local running = true

device:setup()
ui:setup()

--------------------------------------------------------------------------------
-- Home Stack
--------------------------------------------------------------------------------

function lifeLoop()
    local msg
    msg = device:getMessage('noblock')
    if msg then onDeviceMessage(msg); msg = nil end
    msg = ui:getMessage('noblock')
    if msg then onUIMessage(msg) end
end

function onDeviceMessage(msg)
    log('Message: sender,type,data', msg.sender, msg.type, msg.data)
    if msg.type == 'get' then 
        device:sendResponse({
            data='foo'
        })
    elseif msg.type == 'send' then 
        evt = msg.data;

        if evt.type == 'update' then
            evt.data = device_mapper.mapToUI(evt.data)
            evt.id = evt.data.id
        end
        ui:distribute({
            sender = 'home_stack',
            type   = msg.type,
            data   = evt
        })
        if evt.type == 'update' then
            local event = scene_engine.check(evt.data)
            if event then
                event.id = device_mapper.getRawDeviceId(event)
                device:distribute({
                    sender = 'home_stack',
                    type   = msg.type,
                    data   = event
                })
            end
        end
    else
        ui:distribute({
            sender = 'home_stack',
            type   = msg.type,
            data   = msg.data
        })
    end
end

function onUIMessage(msg)
    log('UI Message: ', msg.sender, msg.type, msg.data)
    if msg.type == 'get' then
        if msg.data == 'devicelist' then
            local list = getDeviceResponse('devicelist')
            ui:sendResponse(device_mapper.mapToUI(list.data))
        elseif msg.data == 'scenelist' then
            local list = scene_engine.getScenes()
            ui:sendResponse(list)
        end
    elseif msg.type == 'send' then
        evt = msg.data;
        if evt.type == 'updatedevice' then
            device_mapper.updateDevice(evt.data)
        elseif evt.type == 'deletedevice' then
            device_mapper.deleteDevice(evt.data)
        elseif evt.type == 'addscene' then
            scene_engine.add(evt.data)
        elseif evt.type == 'deletescene' then
            scene_engine.delete(evt.data)
        elseif evt.type == 'setstate' then
            msg.data.id = device_mapper.getRawDeviceId(msg.data)
            device:distribute({
                sender = 'home_stack',
                type   = msg.type,
                data   = msg.data
            })
        end
    end
end

function getDeviceResponse(get)
    device:distribute({
        sender = 'home_stack',
        type   = 'get',
        data   = get
    })
    local got = false;
    local msg
    while not got do 
        msg = device:getMessage()
        if msg.type == 'response' then got = true
        else onDeviceMessage(msg) end
    end
    return msg
end

log('Running ...')
while running do lifeLoop() end
log('Stopped.')

