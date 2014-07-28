
local bus_server = require('lib.bus.server')

local comm    = bus_server:new()
local running = true
local log = function(...) print('<:> Comm Stack <:>', ...) end

comm:setup()

local parseFilter = function(msg)
    local filter, data
    -- filter!
    return filter, data
end

local treat_msg = function(msg)
    if msg.type == 'response' then
        comm:sendResponse(msg)
    else
        comm:distribute(msg)
    end
end

local life_loop = function()
    treat_msg(comm:getMessage())
end

log('Running ...')
while running do life_loop() end
log('Stopped.')

