
--------------------------------------------------------------------------------
-- db
--
-- This module provides database access to Home Stack.
--
-- The Home Stack database is used to store only device customizations made by
-- the user, such as a custom device name. The database does not contain
-- information about the device itself, such as type or capabilities.
--------------------------------------------------------------------------------

local db = {}
local sqlite3 = require('lsqlite3')

--------------------------------------------------------------------------------
-- Creates database (if needed) and loads device data to memory.
--------------------------------------------------------------------------------

function db.setup() 
    local con   = assert(sqlite3.open('apps/home_stack/data/data.db'),
            "Could not open 'data.db'")
    local file  = assert(io.open('apps/home_stack/data/setup.sql'),
            "Database setup.sql not found!")
    local query = ""
    for q in file:lines() do query = query .. q end
    con:exec(query)
    file:close()
    db.con = con
end

--------------------------------------------------------------------------------
-- Returns a list of the devices on the database. 
-- Each item on the list is in the form {id=#,id_device=#,name=""}
--------------------------------------------------------------------------------

function db.getDevices()
    local select_stmt = assert(db.con:prepare("SELECT * FROM device;"))
    local devices = {}
    for row in select_stmt:nrows() do
        table.insert(devices, row)
    end
    return devices
end

--------------------------------------------------------------------------------
-- Returns the device with the given id_device, if exists.
-- 
-- @param id_device The real device id of the device object.
-- @return table The device retrieced from database, if exists.
--------------------------------------------------------------------------------

function db.getDevice(id_device)
    if not id_device then return nil end
    local query = 'SELECT * FROM device WHERE id_device = '..id_device..';'
    local select_stmt = assert(db.con:prepare(query))
    local device = {}
    for row in select_stmt:nrows() do
        table.insert(device, row)
    end
    return device
end

--------------------------------------------------------------------------------
-- Adds a device to the database. The device must be a table, containing at
-- least {id_device=#,name="",type=""}.
--
-- @param device The device to be added.
--------------------------------------------------------------------------------

function db.addDevice(device)
    local query = 'INSERT INTO device ("id_device", "name", "type") '
                ..'VALUES ('..device.id_device..',"'..device.name..'","'
                ..device.type..'");'
    db.con:exec(query)
end

--------------------------------------------------------------------------------
-- Updates a device in thedatabase. The device must be a table, containing at
-- least {id_device=#,name="",type=""}.
--
-- @param device The device to be updated.
--------------------------------------------------------------------------------

function db.updateDevice(device)
    local query = 'UPDATE device '
                ..'SET name = "'..device.name..'", type = "'..device.type..'" '
                ..'WHERE id_device = '..device.id_device..';'
    db.con:exec(query)
end

--------------------------------------------------------------------------------
-- Deletes a device in the database. The device must be a table, containing at
-- least {id_device=#}.
--
-- @param device The device to be deleted.
--------------------------------------------------------------------------------

function db.deleteDevice(device)
    local query = 'DELETE FROM device WHERE id_device = '..device.id_device..';'
    db.con:exec(query)
end

db.setup()
return db

