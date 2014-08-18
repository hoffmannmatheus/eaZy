
--------------------------------------------------------------------------------
-- Device Mapper 
--
-- This module maps User devices to real devices retrieved from Device Controller.
--------------------------------------------------------------------------------
--[{'name': 'Smart Energy Switch', 'type': 'appliance',
--'consumption_accumulated': '0.252000004053', 'state': 'on',
--'consumption_current': '0.375', 'id': 3}, 
--{'luminance': None, 'temperature':
--None, 'presence': 'off', 'type': 'sensor', 'id': 4, 'name': 'EZMotion+ 3-in-1
--Sensor'}, 
--{'name': 'Smart Energy Switch', 'type': 'appliance',
--'consumption_accumulated': '0.0', 'state': 'on', 'consumption_current': '0.0',
--'id': 5}]

local mock_list = {
    {
    id=1,
    registration="registered",
    name="My Cute Appliace",
    },
    {
    id=2,
    registration="registered",
    name="LG Monitor",
    },
    {
    id=3,
    registration="registered",
    name="Multisensor",
    }
}

local mock_id_map = {
   [3] = 1,
   [4] = 3,
   [5] = 2 
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
    for k, device in pairs(raw_list) do
        local id = id_map[device.id]
        -- get the user device
        local user_prefs = device_mapper.getUserDeviceById(id)
        if not user_prefs then
            -- unknown device
            device.registration='unregistered'
        else
            -- add user settings to the object
            for key, value in pairs(user_prefs) do
                device[key] = value -- fill device with user settings
            end
        end
        -- fix strings to numeric values
        if device.consumption_accumulated then
            device.consumption_accumulated =
                    tonumber(device.consumption_accumulated)
        end
        if device.consumption_current then
            device.consumption_current =
                    tonumber(device.consumption_current)
        end
        if device.temperature then
            device.temperature = tonumber(device.temperature)
        end
        if device.luminance then
            device.luminance = tonumber(device.luminance)
        end
        print("device:")
        log(device)
        table.insert(user_list, device)
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
