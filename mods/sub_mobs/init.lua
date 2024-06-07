sub_mobs = {}

--Get rid of gravity, we're working underwater
sub_mobs.gravity = -4
mobkit.gravity = 0

--Spawning mechanism
sub_mobs.registered_spawns = {}

function sub_mobs.register_spawn(defs)
    defs.name = defs.name
    defs.biomes = defs.biomes or {}
    defs.nodes = defs.nodes or {}
    for i, biome in pairs(defs.biomes) do
        table.insert(defs.nodes, sub_core.registered_biomes[biome].node_water)
    end
    defs.chance = defs.chance or 0
    defs.count = defs.count or 1
    defs.count_max = defs.count_max or defs.count
    defs.reduction = defs.reduction or 0
    defs.dist = defs.dist or 50
    defs.height_min = defs.height or 0
    defs.height_max = defs.height_max or 1
    table.insert(sub_mobs.registered_spawns, defs)
end

minetest.register_globalstep(function (dtime)
    for _ = 1, 8 do
        --choose mob to spawn
        local defs = sub_mobs.registered_spawns[math.random(#sub_mobs.registered_spawns)]

        --choose spawn position and check if there is space
        local spawnpos = mobkit.get_spawn_pos_abr(dtime, 1, defs.dist, defs.chance, defs.reduction)
        if spawnpos and #minetest.get_objects_inside_radius(spawnpos, 100) < 50 then
            spawnpos = spawnpos+vector.new(0, 1, 0) --to bring it off the ground
            spawnpos.y = spawnpos.y*(1-math.random(defs.height_min*1000, defs.height_max*1000)*0.001)

            --check if correct node to spawn in
            for i, node in ipairs(defs.nodes) do
                if minetest.get_node(spawnpos).name == node then

                    --attempt to spawn the mob or mobs
                    for _ = 1, math.random(defs.count, defs.count_max) do
                        minetest.add_entity(spawnpos, defs.name)
                        --minetest.log("Spawned "..defs.name)
                    end
                    return
                end
            end
        end
    end
end)

--Load files for each mob
local path = minetest.get_modpath("sub_mobs").."/"
dofile(path.."behaviors.lua")
dofile(path.."smallfish.lua")
dofile(path.."parasites.lua")
dofile(path.."crashfish.lua")
dofile(path.."gasopod.lua")
dofile(path.."skyray.lua")
dofile(path.."rays.lua")
dofile(path.."sandshark.lua")
dofile(path.."reefback.lua")