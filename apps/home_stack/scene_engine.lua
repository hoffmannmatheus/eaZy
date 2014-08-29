
--------------------------------------------------------------------------------
-- Scene Engine
--
-- Module responsible for acknowledging and creating actions for user defined
-- scenes.
--------------------------------------------------------------------------------

local scene_engine = {}
local db = require('apps.home_stack.data.db')

local cached_scenes
local db_updated = false

--------------------------------------------------------------------------------
-- Returns all scenes, as an array of Scene tables.
--
-- @return table The scene list.
--------------------------------------------------------------------------------

function scene_engine.getScenes()
    if db_updated or not cached_scenes then
        cached_scenes = db.getScenes()
    end
    db_updated = false
    return cached_scenes
end

--------------------------------------------------------------------------------
-- Adds a scene to the database.
--
-- @param scene The new scene to be added. Must be a Scene table.
--------------------------------------------------------------------------------

function scene_engine.add(scene)
    if scene and scene.source_device and scene.source_attr and scene.souce_value 
            and scene.target_device and scene.target_state then
        db.addScene(scene)
        db_updated = true
    end
end

--------------------------------------------------------------------------------
-- Deletes a scene from the database.
--
-- @param scene The scene to be deleted
--------------------------------------------------------------------------------

function scene_engine.delete(scene)
    if scene and scene.id then
        db.deleteScene(scene)
        db_updated = true
    end
end

--------------------------------------------------------------------------------
-- Checks the device states to verify if there is any associated scenes.
--
-- @param device The device with updated attributes to be checked.
-- @return table The scene event, if any, with the type 'setstate' to be sent to
-- the device controller.
--------------------------------------------------------------------------------

function scene_engine.check(device)
    local scenes = scene_engine.getScenes()
    local scene = nil
    local event = nil
    for _, s in pairs(scenes) do
        if s.source_device == device.id then
            scene = s
        end
    end
    if not scene then return nil end
    if not device[scene.source_attr] then return nil end
    if device[scene.source_attr] == scene.source_value then
        event = {
            id    = scene.target_device,
            state = scene.target_state,
            type  = "setstate"
        }
    end 
    return event
end

return scene_engine

