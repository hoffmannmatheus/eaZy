
local bus_server = require('lib.bus.server')

-- make initial setup
-- - check configs stuff and so on

local comm    = bus_server:new(--[[config]])
local running = true

local parseFilter = function(msg)
    local filter, data
    -- filter!
    return filter, data
end

local treat_msg = function(msg)
    local filter, data = parseFilter(msg)
    comm.distribute(filter, data)
end

local life_loop = function()
    local msg
    msg = comm.check_income()
end

print('Running Comm Stack...')
while running do life_loop() end
print('Stopping Comm Stack.')

