sub_vehicles = {}

--HUDs for vehicle health and power
local health_huds = {}

function sub_vehicles.add_huds(player, vehicle)
    health_huds[player] = player:hud_add({
        hud_elem_type = "statbar",
        position = {x=0.5, y=1},
        size = {x=24, y=24},
        alignment = {x=-1, y=-1},
        offset = {x=-265, y=-155},
        text = "sub_vehicles_health_hud.png",
        number = 20*vehicle:get_hp()/vehicle:get_properties().hp_max
    })
end

function sub_vehicles.update_huds(player)
    local vehicle = player:get_attach()
    player:hud_change(health_huds[player], "number", 20*vehicle:get_hp()/vehicle:get_properties().hp_max)
end

function sub_vehicles.remove_huds(player)
    player:hud_remove(health_huds[player])
    health_huds[player] = nil
end

local path = minetest.get_modpath("sub_vehicles").."/"
dofile(path.."seamoth.lua")
dofile(path.."constructor.lua")