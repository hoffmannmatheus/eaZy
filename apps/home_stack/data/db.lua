
--------------------------------------------------------------------------------
-- db
--
-- This module provides database access to Home Stack.
--
-- The Home Stack database is used to store only device customizations made by
-- the user, such as a custom device name. The database does not contain
-- information about the device itself, such as device capabilities.
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
--
-- @return table The device list.
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
-- @return boolean True if command was successfully executed, false otherwise.
--------------------------------------------------------------------------------

function db.addDevice(device)
    local query = 'INSERT INTO device ("id_device", "name", "type") '
                ..'VALUES ('..device.id_device..',"'..device.name..'","'
                ..device.type..'");'
    db.con:exec(query)
    return true
end

--------------------------------------------------------------------------------
-- Updates a device in thedatabase. The device must be a table, containing at
-- least {id_device=#,name="",type=""}.
--
-- @param device The device to be updated.
-- @return boolean True if command was successfully executed, false otherwise.
--------------------------------------------------------------------------------

function db.updateDevice(device)
    local query = 'UPDATE device '
                ..'SET name = "'..device.name..'", type = "'..device.type..'" '
                ..'WHERE id_device = '..device.id_device..';'
    db.con:exec(query)
    return true
end

--------------------------------------------------------------------------------
-- Deletes a device in the database. The device must be a table, containing at
-- least {id_device=#}.
--
-- @param device The device to be deleted.
-- @return boolean True if command was successfully executed, false otherwise.
--------------------------------------------------------------------------------

function db.deleteDevice(device)
    local query = 'DELETE FROM device WHERE id_device = '..device.id_device..';'
    db.con:exec(query)
    return true
end

--------------------------------------------------------------------------------
-- Returns a list of the scene on the database. 
-- Each item on the list is a scene table.
--
-- @return table The list of scenes.
--------------------------------------------------------------------------------

function db.getScenes()
    local select_stmt = assert(db.con:prepare("SELECT * FROM scene;"))
    local scenes
    for row in select_stmt:nrows() do
        table.insert(scenes, row)
    end
    return scenes
end

--------------------------------------------------------------------------------
-- Adds a scene to the database. The device must be a table, like:
--   {source_device=#,source_attr="",source_value="",target_device=#,
--     target_state=""}.
--
-- @param scene The scene to be added.
-- @return boolean True if command was successfully executed, false otherwise.
--------------------------------------------------------------------------------

function db.addScene(scene)
    local query = 'INSERT INTO scene ("source_device", "source_attr", '
                ..'"source_value", "target_device", "target_state") VALUES ('
                ..scene.source_device.. ',"'
                ..scene.source_attr..   '","'
                ..scene.source_value..  '",'
                ..scene.target_device.. ',"'
                ..scene.target_state..  '");'
    db.con:exec(query)
    return true
end

--------------------------------------------------------------------------------
-- Deletes a scene in the database. The param must be the scene table, which 
-- contains the scene database id.
--
-- @param scene The scene to be deleted.
-- @return boolean True if command was successfully executed, false otherwise.
--------------------------------------------------------------------------------

function db.deleteScene(scene)
    if not scene or not scene.id then return false end
    local query = 'DELETE FROM scene WHERE id = '..scene.id..';'
    db.con:exec(query)
    return true
end

db.setup()
return db

