
--------------------------------------------------------------------------------
-- Device Mapper 
--
-- This module manages UI devices by mapping them to real devices retrieved 
-- from Device Controller.
-- The mapping is important so that the 'raw' devices retrieved by the
-- device controller can be turned into 'ui' devices, containing user 
-- preferences for that specific device such as a custom device name.
--
-- If a device is unknown to the Device Mapper, it will be returned as the 'raw'
-- device plus an attribute 'registration', set to 'unregistered'.
--------------------------------------------------------------------------------

local device_mapper = {}
local db = require('apps.home_stack.data.db')

--------------------------------------------------------------------------------
-- Maps a Raw Device List (eg. list got from Device Controller with real device
-- ID's) to a UI Device List (eg. devices with ui custom attributes).
--
-- @param raw_list A device or device list retrieved directly from 
-- device_controller.
--------------------------------------------------------------------------------

function device_mapper.map(raw_list) 
    if not raw_list then return {} end
    local ui_devices = db.getDevices()

    local fixDevice = function(device)
        -- get the ui device
        local ui_prefs = false
        for k, d in pairs(ui_devices) do
            if device.id_device == d.id_device then ui_prefs = d end
        end
        if not ui_prefs then
            -- unknown device
            device.registration='unregistered'
            device.id = device.id_device
        else
            -- add settings to the object
            for key, value in pairs(ui_prefs) do
                if key ~= 'type' then
                    device[key] = value -- fill device with ui settings
                end
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
        local list = {}
        for k, device in pairs(raw_list) do
            table.insert(list, fixDevice(device))
        end
        -- check if any device known by the DB is missing
        for k, ui_dev in ipairs(ui_devices) do
            local found = false
            for j, dev in ipairs(list) do
                if ui_dev.id_device == dev.id_device then
                    found = true
                end
            end
            if not found then -- if not, device to list
                ui_dev.registration = 'missing'
                table.insert(list, ui_dev)
            end
        end
        return list
    end
end

--------------------------------------------------------------------------------
-- Updates the device in Home Stack, setting new user preferences to it. If the
-- device is present on the database (identified by 'id_device') it is updated,
-- and if not, it is added.
--
-- @param device The device object with updated values (should contain the
-- device UI id.
--------------------------------------------------------------------------------

function device_mapper.updateDevice(device)
    if not device or not device.id_device or not device.type 
            or not device.name then
        return print('ERR: Cannot update device.')
    end
    local stored = db.getDevice(device.id_device)
    if stored and next(stored) then
        db.updateDevice(device)
    else
        db.addDevice(device)
    end
end

--------------------------------------------------------------------------------
-- Deletes a device, removing it from the HomeStack database.
--
-- @param device The device object to be deleted from the database.
--------------------------------------------------------------------------------

function device_mapper.deleteDevice(device)
    if not device or not device.id or not device.id_device then
        return nil
    end
    db.deleteDevice(device)
end

--------------------------------------------------------------------------------
-- Gets a Raw Device ID.
--
-- @param id The UI Device ID.
--------------------------------------------------------------------------------

function device_mapper.getRawDeviceId(id)
    local id_map = device_mapper.buildIdMap()
    for raw_id, ui_id in pairs(id_map) do
        if ui_id == id then return raw_id end
    end
end

--------------------------------------------------------------------------------
-- Mounts an id_map [device_id, ui_id]
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

