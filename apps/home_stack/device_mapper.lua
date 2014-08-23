
--------------------------------------------------------------------------------
-- Device Mapper 
--
-- This module maps User devices to real devices retrieved from Device Controller.
-- The mapping is important so that the 'raw' devices retrieved by the
-- controller can be turned into 'user' devices, containing user preferences for
-- that specific device such as a custom device name.
--
-- If a device is unknown to the Device Mapper, it will be returned as the 'raw'
-- device plus an attribute 'registration', set to 'unregistered'.
--------------------------------------------------------------------------------

local device_mapper = {}
local db = require('apps.home_stack.data.db')

--------------------------------------------------------------------------------
-- Maps a Raw Device List (eg. list got from Device Controller with real device
-- ID's) to a User Device List (eg. devices with user custom attributes).
--
-- @param raw_list A device or device list retrieved directly from 
-- device_controller.
--------------------------------------------------------------------------------

function device_mapper.map(raw_list) 
    if not raw_list then return {} end
    local user_devices = db.getDevices()
    local id_map = device_mapper.buildIdMap(user_devices)
    local fixDevice = function(device)
        local id = id_map[device.id]
        -- get the user device
        local user_prefs = false
        for k, device in pairs(user_devices) do
            if device.id == id then user_prefs = device end
        end
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
        return device
    end

    if #raw_list == 0 and next(raw_list) then -- single device
        return fixDevice(raw_list)
    else -- device list
        local user_list = {}
        for k, device in pairs(raw_list) do
            table.insert(user_list, fixDevice(device))
        end
        return user_list
    end
end

--------------------------------------------------------------------------------
-- Gets a Raw Device ID.
--
-- @param id The User Device ID.
--------------------------------------------------------------------------------

function device_mapper.getRawDeviceId(id)
    local id_map = device_mapper.buildIdMap()
    for raw_id, user_id in pairs(id_map) do
        if user_id == id then return raw_id end
    end
end

--------------------------------------------------------------------------------
-- Mounts an id_map [device_id, user_id]
--
-- @param list Device list retrieved from db.getDevices. If not given, will
-- retrieve the list from the database.
--------------------------------------------------------------------------------

function device_mapper.buildIdMap(list)
    list = list or db.getDevices()
    local id_map = {}
    for _, d in ipairs(list) do
        id_map[d.id_device] = d.id
    end
    return id_map
end

return device_mapper

