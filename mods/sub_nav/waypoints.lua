local storage = minetest.get_mod_storage()

--Register functions to do upon initializing storage
sub_nav.registered_on_loads = {}

function sub_nav.register_on_load(func)
    table.insert(sub_nav.registered_on_loads, func)
end

minetest.register_on_mods_loaded(function()
    if storage:get_string("waypoints") == "" then
        storage:set_string("waypoints", "return {}")
        for i, func in ipairs(sub_nav.registered_on_loads) do func() end
    end
end)

--Set waypoint for all players at given position, returns id
function sub_nav.set_waypoint(pos, defs)
    local data = minetest.deserialize(storage:get_string("waypoints"))
    local next = storage:get_int("next_waypoint")+1
    data[next] = {pos, defs}
    storage:set_string("waypoints", minetest.serialize(data))
    storage:set_int("next_waypoint", next)
    return next
end

--Change position of specified waypoint, returns success
function sub_nav.move_waypoint(id, pos)
    local data = minetest.deserialize(storage:get_string("waypoints"))
    if not data[id] then return false end
    data[id] = {pos, data[id][2]}
    storage:set_string("waypoints", minetest.serialize(data))
    return true
end

--Remove waypoint
function sub_nav.remove_waypoint(id)
    local data = minetest.deserialize(storage:get_string("waypoints"))
    data[id] = nil
    storage:set_string("waypoints", minetest.serialize(data))
end

--Iterate over waypoints
function sub_nav.waypoint_pairs()
    local data = minetest.deserialize(storage:get_string("waypoints"))
    local i, entry
    local function iter(d)
        i, entry = next(d, i)
        if entry then return entry[1], entry[2] end
    end
    return iter, data, nil
end

--Update waypoints for a particular player
local player_huds = {}

function sub_nav.update(player)
    local name = player:get_player_name()
    if not player_huds[name] then player_huds[name] = {} end
    for i, id in ipairs(player_huds[name]) do player:hud_remove(id) end
    player_huds[name] = {}
    local player_pos = player:get_pos()
    for pos, defs in sub_nav.waypoint_pairs() do
        if vector.distance(player_pos, pos) >= defs.dist then
            table.insert(player_huds[name], player:hud_add({
                name = defs.name,
                hud_elem_type = "waypoint",
                offset = {x=0, y=-80},
                z_index = -300,
                precision = 1,
                text = "m",
                number = 0x00ffff,
                world_pos = pos
            }))
            table.insert(player_huds[name], player:hud_add({
                hud_elem_type = "image_waypoint",
                scale = {x=6, y=6},
                z_index = -300,
                text = defs.image.."^[multiply:#00ffff",
                world_pos = pos
            }))
        end
    end
end

minetest.register_on_joinplayer(sub_nav.update)

--Update waypoints for all players
function sub_nav.update_all()
    for i, player in ipairs(minetest.get_connected_players()) do
        sub_nav.update(player)
    end
end

minetest.register_globalstep(sub_nav.update_all)