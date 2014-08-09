
local bus_server = require('lib.bus.server')

local comm    = bus_server:new()
local running = true
local log = function(...) print('<:> Comm Stack <:>', ...) end

comm:setup()

local life_loop = function()
    local msg = comm:getMessage()
    if msg.type == 'response' then
        comm:sendResponse(msg)
    else
        comm:distribute(msg)
    end
end

log('Running ...')
while running do life_loop() end
log('Stopped.')

