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
    defs.gen_chance = defs.gen_chance or 0
    defs.count = defs.count or 1
    defs.count_max = defs.count_max or defs.count
    defs.reduction = defs.reduction or 0
    defs.dist = defs.dist or 50
    defs.height_min = defs.height_min or -31000
    defs.height_max = defs.height_max or 0
    table.insert(sub_mobs.registered_spawns, defs)
end

minetest.register_globalstep(function (dtime)
    for _ = 1, 8 do
        --choose mob to spawn
        local defs = sub_mobs.registered_spawns[math.random(#sub_mobs.registered_spawns)]

        --choose spawn position and check if there is space
        local spawnpos = mobkit.get_spawn_pos_abr(dtime, 1, defs.dist, defs.chance, defs.reduction)
        if spawnpos and #minetest.get_objects_inside_radius(spawnpos, 200) < 50 then
            spawnpos = spawnpos+vector.new(0, 1, 0) --to bring it off the ground
            spawnpos.y = math.random(math.max(spawnpos.y, defs.height_min), defs.height_max)

            --check if correct node to spawn in
            local nodename = minetest.get_node(spawnpos).name
            for i, node in ipairs(defs.nodes) do
                if nodename == node then

                    --attempt to spawn the mob or mobs
                    for _ = 1, math.random(defs.count, defs.count_max) do
                        minetest.add_entity(spawnpos, defs.name)
                    end
                    return
                end
            end
        end
    end
end)

local function attempt_spawn(minp, maxp, rand, vm, defs)
    for _ = 1, 8 do
        --choose spawn position and check if correct node to spawn in
        local spawnpos = vector.new(rand:next(minp.x, maxp.x), rand:next(minp.y, maxp.y), rand:next(minp.z, maxp.z))
        local nodename = vm:get_node_at(spawnpos).name
        if spawnpos.y > defs.height_min and spawnpos.y < defs.height_max and sub_mobs.containsi(defs.nodes, nodename) then

            --attempt to spawn the mob or mobs
            for _ = 1, math.random(defs.count, defs.count_max) do
                minetest.add_entity(spawnpos, defs.name)
            end
            minetest.log("spawned "..defs.name)
            return
        end
    end
end

sub_core.register_on_generate(function (minp, maxp, seed, vm)
    local rand = PcgRandom(seed) --hence mobs should depend solely on seed
    for i, defs in ipairs(sub_mobs.registered_spawns) do
        if math.abs(rand:next())%1000000 < defs.gen_chance*1000000 then
            attempt_spawn(minp, maxp, rand, vm, defs)
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
dofile(path.."stalker.lua")
dofile(path.."sandshark.lua")
dofile(path.."reefback.lua")
dofile(path.."reaper.lua")