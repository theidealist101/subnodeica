--DATA FUNCTIONS

--Tables for perlin noise functions of heat and humidity
local heat_table = {
    offset = 50,
    scale = 40,
    spread = {x=300, y=300, z=300},
    seed = 101,
    octaves = 5,
    persistence = 0.5,
    lacunarity = 2.0
}

local level_table = {
    offset = 0,
    scale = 400,
    spread = {x=500, y=500, z=500},
    seed = 103,
    octaves = 4,
    persistence = 0.5,
    lacunarity = 2.0
}

local height_table = {
    offset = 0,
    scale = 40,
    spread = {x=500, y=500, z=500},
    seed = 104,
    octaves = 5,
    persistence = 0.5,
    lacunarity = 2.0
}

local SLOPE_POWER = 6
local SLOPE_COEFF = 1/(250*25^(-1/SLOPE_POWER))^SLOPE_POWER

--Register biomes with parameters needed by this mapgen
sub_core.registered_biomes = {}

function sub_core.register_biome(name, defs)
    defs.name = defs.name or ""
    defs.not_generated = defs.not_generated or false
    defs.node_top = defs.node_top or nil --to be switched with mapgen_stone later
    defs.node_stone = defs.node_stone or nil --ditto
    defs.node_water_surface = defs.node_water_surface or defs.node_water and defs.node_water.."_surface" or "air"
    defs.node_water = defs.node_water or "air"
    defs.height_point = defs.height_point or 0
    defs.heat_point = defs.heat_point or 50
    --add it to the global table
    sub_core.registered_biomes[name] = defs
end

--Register decoration
sub_core.registered_decors = {}

function sub_core.register_decor(defs)
    defs.type = defs.type or "top"
    defs.fill_ratio = defs.fill_ratio or 1
    defs.biome = defs.biome
    if not minetest.registered_nodes[defs.decor] then
        defs.decor = sub_core.get_waterlogged(defs.decor, sub_core.registered_biomes[defs.biome].node_water)
    end
    defs.place_under = defs.place_under
    defs.noise = defs.noise
    defs.param2 = defs.param2 or 0
    defs.max_param2 = defs.max_param2
    --add it to the global table
    table.insert(sub_core.registered_decors, defs)
    return #sub_core.registered_decors
end

sub_core.registered_spawners = {}

function sub_core.register_spawner(name, exposed, hidden, defs)
    defs = table.copy(defs)
    defs.groups = defs.groups or {}
    defs.groups.spawner = 1
    minetest.register_node(name.."_spawner", defs)
    sub_core.registered_spawners[name.."_spawner"] = {exposed, hidden, name}
end

sub_core.registered_schems = {}

function sub_core.register_schem(defs)
    defs.type = defs.type or "top"
    defs.fill_ratio = defs.fill_ratio or 1
    defs.biome = defs.biome
    defs.radius = defs.radius or 0
    defs.schem = defs.schem
    table.insert(sub_core.registered_schems, defs)
    return #sub_core.registered_schems
end

--Register on_generated function to call after generating terrain
sub_core.registered_on_generate = {}

function sub_core.register_on_generate(func)
    table.insert(sub_core.registered_on_generate, func)
end

--SETUP FOR MAPGEN

--Important tables localized outside and reused to avoid extra memory usage
local vm_data = {}
local param2_data = {}
local heat_data = {}
local level_data = {}
local height_data = {}
local decor_data = {}
local rand_data = {}
local biome_data = {}

--Initializing the perlin maps and positions of important stuff
local heat_map, level_map, height_map
local initialized = false

local function init(size)
    local c_stone = minetest.get_content_id("mapgen_stone")
    for name, defs in pairs(sub_core.registered_biomes) do
        if defs.node_top then defs.node_top_id = minetest.get_content_id(defs.node_top) else defs.node_top_id = c_stone end
        if defs.node_stone then defs.node_stone_id = minetest.get_content_id(defs.node_stone) else defs.node_stone_id = c_stone end
        defs.node_water_id = minetest.get_content_id(defs.node_water)
        defs.node_water_surface_id = minetest.get_content_id(defs.node_water_surface)
    end
    for i, defs in ipairs(sub_core.registered_decors) do
        defs.decor_id = minetest.get_content_id(defs.decor)
        if defs.place_under then defs.place_under_id = minetest.get_content_id(defs.place_under) end
        if defs.noise then defs.noise_map = minetest.get_perlin_map(defs.noise, {x=size, y=size+2, z=size}) end
        table.insert(decor_data, {})
        table.insert(rand_data, {})
    end
    heat_map = minetest.get_perlin_map(heat_table, {x=size, y=size})
    level_map = minetest.get_perlin_map(level_table, {x=size, y=size})
    height_map = minetest.get_perlin_map(height_table, {x=size, y=size})
end

--FUNCTIONS FOR MAPGEN

--Set up noise map for each chunk
local function get_maps(minp, seed)
    local minp2d = {x=minp.x, y=minp.z}
    local minp3d = {x=minp.x, y=minp.y-1, z=minp.z}
    heat_map:get_2d_map_flat(minp2d, heat_data)
    level_map:get_2d_map_flat(minp2d, level_data)
    height_map:get_2d_map_flat(minp2d, height_data)
    for i, defs in ipairs(sub_core.registered_decors) do
        if defs.noise then defs.noise_map:get_3d_map_flat(minp3d, decor_data[i]) end
        rand_data[i] = PcgRandom(seed+i+minp.x*PcgRandom(minp.y+minp.z^2):next(0, 99999))
    end
end

--Set up VM for each chunk
local function get_vm()
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
    vm:get_data(vm_data)
    vm:get_param2_data(param2_data)
    return vm, area
end

--Get height (without small details)
local function get_height_data(ni, pos)
    local dist = math.sqrt(pos.x^2+pos.z^2)
    local level = level_data[ni]+dist
    local height_offset = height_data[ni]*(dist < 500 and 0.5+0.001*dist or 1)+20-0.01*dist
    local height = level < 250 and -50
        or level < 500 and -SLOPE_COEFF*(level-250)^SLOPE_POWER-50
        or level < 750 and SLOPE_COEFF*(level-750)^SLOPE_POWER-100
        or level < 1000 and -2*SLOPE_COEFF*(level-750)^SLOPE_POWER-100
        or level < 1250 and 2*SLOPE_COEFF*(level-1250)^SLOPE_POWER-200
        or level < 1750 and -200
        or -8*SLOPE_COEFF*(level-1750)^SLOPE_POWER-200
    return height+height_offset
end

--Get biome data from internal mapgen variables
local function get_biome_data(pos, ni, height)
    if not biome_data[pos.x] then biome_data[pos.x] = {} end
    local biome = biome_data[pos.x][pos.z]
    if not biome then
        local heat = heat_data[ni]
        for i, defs in pairs(sub_core.registered_biomes) do
            if not defs.not_generated then
                local biome_dist_sq = (height-defs.height_point)^2+(heat-defs.heat_point)^2
                local biome_dist_tuple = {i, defs, biome_dist_sq}
                if not biome or biome_dist_sq < biome[3] then
                    biome = biome_dist_tuple
                end
            end
        end
        if not biome then biome = {sub_core.biome_default, sub_core.registered_biomes[sub_core.biome_default], 0} end
        biome_data[pos.x][pos.z] = biome
    end
    return biome[1], biome[2]
end

--Get density similarly
local function get_density(height, ni, ni3d, y, size, biome)
    local density_below = y-height-1
    local density = y-height
    local density_above = y-height+1
    return density_below, density, density_above
end

--Choose basic biome node to place
local function choose_base_node(y, bdefs, density, density_above)
    if density <= 0 then
        if density_above <= 0 then
            return bdefs.node_stone_id
        else
            return bdefs.node_top_id
        end
    elseif y == 0 then
        return bdefs.node_water_surface_id
    elseif y < 0 then
        return bdefs.node_water_id
    end
    return minetest.CONTENT_AIR
end

--Place decorations using internal stuff, designed to be deterministic per position
local function place_decors(ni3d, biome, density_below, density, density_above, param2_rand)
    for i, defs in ipairs(sub_core.registered_decors) do
        if rand_data[i]:next(0, 99999) < defs.fill_ratio*100000 and defs.biome == biome
        and (not defs.noise or decor_data[i][ni3d] > 0) then
            if (defs.type == "underground" and density <= 0 and density_above <= 0 and density_below <= 0)
            or (defs.type == "surface" and density <= 0 and density_above > 0)
            or (defs.type == "bottom" and density > 0 and density_above <= 0)
            or (defs.type == "top" and density_below <= 0 and density > 0) then
                return defs.decor_id, (defs.max_param2 and param2_rand:next(defs.param2, defs.max_param2)) or defs.param2
            end
        end
    end
end

--Add schems to list of schems to be loaded here
local function get_schems(pos, schem_places, biome, density_below, density, density_above, schem_rand)
    for i, defs in ipairs(sub_core.registered_schems) do
        if schem_rand:next(0, 99999) < defs.fill_ratio*100000 and defs.biome == biome
        and ((defs.type == "underground" and density <= 0 and density_above <= 0 and density_below <= 0)
        or (defs.type == "surface" and density <= 0 and density_above > 0)
        or (defs.type == "top" and density_below <= 0 and density > 0)) then
            table.insert(schem_places, {defs, pos})
        end
    end
end

--Place schems in list of schems
local function place_schems(vm, minp, maxp, schem_places)
    for i, place in ipairs(schem_places) do
        local defs, pos = place[1], place[2]
        if minp.x+defs.radius < pos.x and pos.x < maxp.x-defs.radius
        and minp.y+defs.radius < pos.y and pos.y < maxp.y-defs.radius
        and minp.z+defs.radius < pos.z and pos.z < maxp.z-defs.radius then
            minetest.place_schematic_on_vmanip(vm, pos, defs.schem, "random", nil, true, "place_center_x, place_center_z")
        end
    end
end

--MAPGEN

--The actual generating function
minetest.register_on_generated(function (minp, maxp, seed)
    --initialize stuff
    local size = maxp.x-minp.x+1
    if not initialized then
        init(size)
        initialized = true
    end

    --make sure it's not too high
    if minp.y > 0 then return end

    --set up data for chunk
    local vm, area = get_vm()
    local param2_rand = PcgRandom(seed)
    local schem_rand = PcgRandom(-seed)
    local schem_places = {}
    get_maps(minp, seed)

    --loop over each node
    local ni3d = 1
    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            local vi = area:index(minp.x, y, z)
            local ni = size*(z-minp.z)+1
            for x = minp.x, maxp.x do
                --make sure it's not already generated from a neighbouring chunk
                if vm_data[vi] == minetest.CONTENT_AIR then
                    local pos = vector.new(x, y, z)
                    local height = get_height_data(ni, pos)
                    local biome, bdefs = get_biome_data(pos, ni, height)
                    local density_below, density, density_above = get_density(height, ni, ni3d, y, size, biome)

                    local id, param2 = place_decors(ni3d, biome, density_below, density, density_above, param2_rand)
                    if id then
                        vm_data[vi] = id
                        param2_data[vi] = param2
                    else
                        vm_data[vi] = choose_base_node(y, bdefs, density, density_above)
                    end

                    get_schems(pos, schem_places, biome, density_below, density, density_above, schem_rand)
                end

                --increment the index for the next node
                vi = vi+1
                ni = ni+1
                ni3d = ni3d+1
            end
        end
        ni3d = ni3d+size*2
    end

    vm:set_data(vm_data)
    vm:set_param2_data(param2_data)
    place_schems(vm, minp, maxp, schem_places)

    for i, func in ipairs(sub_core.registered_on_generate) do
        func(minp, maxp, seed, vm)
    end

    vm:calc_lighting()
    vm:write_to_map()
    vm:update_liquids()
end)

--ABM updating all spawners
local dirs = {
    vector.new(0, -1, 0),
    vector.new(0, 1, 0),
    vector.new(-1, 0, 0),
    vector.new(1, 0, 0),
    vector.new(0, 0, -1),
    vector.new(0, 0, 1),
}

local function place_spawner(pos, node)
    local defs = sub_core.registered_spawners[node.name]
    local exposed = false
    for i, d in ipairs(dirs) do
        local neighbor = minetest.registered_nodes[minetest.get_node(pos+d).name]
        if neighbor and neighbor.groups.water and neighbor.groups.water > 0 then
            exposed = true
            if math.random() < 0.5 then
                local name
                if not minetest.registered_nodes[defs[3]] then
                    name = sub_core.get_waterlogged(defs[3], neighbor._water_equivalent)
                else name = defs[3] end
                minetest.swap_node(pos+d, {name=name, param2=i-1})
                minetest.swap_node(pos, {name=defs[1]})
                return
            end
        end
    end
    if exposed then minetest.swap_node(pos, {name=defs[1]}) else minetest.swap_node(pos, {name=defs[2]}) end
end

minetest.register_abm({
    nodenames = {"group:spawner"},
    interval = 1,
    chance = 1,
    action = place_spawner
})