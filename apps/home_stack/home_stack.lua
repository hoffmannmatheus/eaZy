
local bus_client = require('lib.bus.client')

-- make initial setup
-- - check configs stuff and so on

local running = true

local comm = bus_client:new({filter='home_stack'})
local ui   = bus_client:new({filter='ui_stack', sub_port=5560, send_port=5561,
        get_port=5562})
comm:setup();
ui:setup();

local treat_comm_msg = function(msg)
    -- middleware logic
    comm.send('{from:"home_stack",data:"hello"}')
end

local treat_ui_msg = function(msg)
    -- middleware logic
end

local life_loop = function()
    local msg
    msg = comm.check_income()
    if msg then treat_comm_msg(msg); msg = nil end
    msg = ui.check_income()
    if msg then treat_ui_msg(msg) end
end

print('Running Home Stack...')
while running do life_loop() end
print('Stopping Home Stack.')

