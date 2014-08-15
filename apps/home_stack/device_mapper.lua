
--------------------------------------------------------------------------------
-- Device Mapper 
--
-- This module maps User devices to real devices retrieved from Device Controller.
--------------------------------------------------------------------------------

local mock_list = {
    {
    id=12345,
    registration="registered",
    name="My Cute Appliace",
    },
    {
    id=1245,
    registration="registered",
    name="A Dishwasher",
    },
    {
    id=32145,
    registration="registered",
    name="Corridor Sensor",
    },
    {
    id=345,
    registration="registered",
    name="Room Light",
    },
    {
    id=3266,
    registration="registered",
    name="Kitchen Temp",
    }
}

local mock_id_map = {
   [1] = 12345,
   [2] = 1245,
   [3] = 32145,
   [4] = 345,
   [5] = 3266
}


local device_mapper = {}

local log = function(dev) for k,v in pairs(dev) do print(k,v) end end
--------------------------------------------------------------------------------
-- Maps a Raw Device List (eg. list got from Device Controller with real device
-- ID's) to a User Device List.
--------------------------------------------------------------------------------

function device_mapper.map(raw_list) 
    local user_list = {}
    local id_map = mock_id_map; -- TODO use real
    for k, raw_device in pairs(raw_list) do
        local id = id_map[raw_device.id]
        local dev = device_mapper.getUserDeviceById(id)
        if not dev then
            print("Unknown device:")
            log(raw_device)
            raw_device.registration='unregistered'
        else
            for key, value in pairs(dev) do
                raw_device[key] = value -- fill device with user settings
            end
        end
        table.insert(user_list, raw_device)
    end
    return user_list
end

--------------------------------------------------------------------------------
-- Gets a User Device by ID
--------------------------------------------------------------------------------

function device_mapper.getUserDeviceById(id)
    local list = mock_list  -- TODO use real
    for k, device in pairs(list) do
        if device.id == id then return device end
    end
end

--------------------------------------------------------------------------------
-- Gets a Raw Device ID
--------------------------------------------------------------------------------

function device_mapper.getRawDeviceId(id)
    local id_map = mock_id_map  -- TODO use real
    for raw_id, user_id in pairs(id_map) do
        if user_id == id then return raw_id end
    end
end

return device_mapper
