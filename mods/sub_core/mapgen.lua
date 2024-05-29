--DATA FUNCTIONS

--Tables for perlin noise functions of heat and humidity
local heat_table = {
    offset = 50,
    scale = 40,
    spread = {x=500, y=500, z=500},
    seed = 101,
    octaves = 5,
    persistence = 0.5,
    lacunarity = 2.0
}

local humid_table = {
    offset = 50,
    scale = 40,
    spread = {x=500, y=500, z=500},
    seed = 102,
    octaves = 5,
    persistence = 0.5,
    lacunarity = 2.0
}

--Register biomes with parameters needed by this mapgen
sub_core.registered_biomes = {}

function sub_core.register_biome(name, defs)
    defs.name = defs.name or ""
    --only for the void, so it doesn't generate except as default
    defs.not_generated = defs.not_generated or false
    defs.node_top = defs.node_top or nil --to be switched with mapgen_stone later
    defs.node_stone = defs.node_stone or nil --ditto
    defs.node_water = defs.node_water or "air"
    defs.vertical_blend = defs.vertical_blend or 0
    --intersperses stone similarly to vertical_blend, and averages the heightmaps (not yet implemented)
    defs.horizontal_blend = defs.horizontal_blend or 0
    defs.y_max = defs.y_max or 31000
    defs.y_min = defs.y_min or -31000
    --how far out it generates
    defs.dist_max = defs.dist_max or 2000 --the start of the void
    defs.dist_min = defs.dist_min or 0
    defs.dist_max_sq = defs.dist_max^2
    defs.dist_min_sq = defs.dist_min^2
    defs.heat_point = defs.heat_point or 50
    defs.humid_point = defs.humid_point or 50 --more about nutrients than humidity though
    --tables for perlin noise functions (each biome gets a different seed)
    defs.noise = defs.noise or {}
    defs.noise.seed = #sub_core.registered_biomes
    defs.noise3d = defs.noise3d or {}
    defs.noise3d.seed = -defs.noise.seed
    --add it to the global table
    sub_core.registered_biomes[name] = defs
end

--Register decoration
sub_core.registered_decors = {}

function sub_core.register_decor(defs)
    defs.type = defs.type or "top"
    defs.fill_ratio = defs.fill_ratio or 1
    defs.biome = defs.biome
    defs.decor = defs.decor
    defs.place_under = defs.place_under
    defs.noise = defs.noise
    defs.max_param2 = defs.max_param2
    --add it to the global table
    table.insert(sub_core.registered_decors, defs)
    return #sub_core.registered_decors
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

--SETUP FOR MAPGEN

--Important tables localized outside and reused to avoid extra memory usage
local vm_data = {}
local param2_data = {}
local heat_data = {}
local humid_data = {}
local terrain_data = {}
local terrain_data3d = {}
local decor_data = {}
local rand_data = {}

--Initializing the perlin maps and positions of important stuff
local heat_map, humid_map
local initialized = false

local function init(size)
    for name, defs in pairs(sub_core.registered_biomes) do
        defs.noise_map = minetest.get_perlin_map(defs.noise, {x=size, y=size})
        defs.noise3d_map = minetest.get_perlin_map(defs.noise3d, {x=size, y=size+2, z=size})
        local c_stone = minetest.get_content_id("mapgen_stone")
        if defs.node_top then defs.node_top_id = minetest.get_content_id(defs.node_top) else defs.node_top_id = c_stone end
        if defs.node_stone then defs.node_stone_id = minetest.get_content_id(defs.node_stone) else defs.node_stone_id = c_stone end
        defs.node_water_id = minetest.get_content_id(defs.node_water)
        defs.node_water_surface_id = minetest.get_content_id(defs.node_water.."_surface")
        terrain_data[name] = {}
        terrain_data3d[name] = {}
    end
    for i, defs in ipairs(sub_core.registered_decors) do
        defs.decor_id = minetest.get_content_id(defs.decor)
        if defs.place_under then defs.place_under_id = minetest.get_content_id(defs.place_under) end
        if defs.noise then defs.noise_map = minetest.get_perlin_map(defs.noise, {x=size, y=size+2, z=size}) end
        table.insert(decor_data, {})
        table.insert(rand_data, {})
    end
    heat_map = minetest.get_perlin_map(heat_table, {x=size, y=size})
    humid_map = minetest.get_perlin_map(humid_table, {x=size, y=size})
end

--FUNCTIONS FOR MAPGEN

--Set up noise map for each chunk
local function get_maps(minp, seed)
    local minp2d = {x=minp.x, y=minp.z}
    local minp3d = {x=minp.x, y=minp.y-1, z=minp.z}
    heat_map:get_2d_map_flat(minp2d, heat_data)
    humid_map:get_2d_map_flat(minp2d, humid_data)
    for name, defs in pairs(sub_core.registered_biomes) do
        defs.noise_map:get_2d_map_flat(minp2d, terrain_data[name])
        defs.noise3d_map:get_3d_map_flat(minp3d, terrain_data3d[name])
    end
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

--Get biome data from internal mapgen variables
local function get_biome_data(ni, pos)
    local heat = heat_data[ni]
    local humid = humid_data[ni]
    local dist_sq = pos.x^2+pos.z^2
    local biome
    for i, defs in pairs(sub_core.registered_biomes) do
        if not defs.not_generated and defs.y_min <= pos.y and pos.y <= defs.y_max
        and defs.dist_min_sq <= dist_sq and dist_sq <= defs.dist_max_sq then
            local biome_dist_sq = (heat-defs.heat_point)^2+(humid-defs.humid_point)^2
            local biome_dist_tuple = {i, defs, biome_dist_sq}
            if not biome or biome_dist_sq < biome[3] then
                biome = biome_dist_tuple
            end
        end
    end
    if not biome then biome = {sub_core.biome_default, sub_core.registered_biomes[sub_core.biome_default], 0} end
    return biome[1], biome[2]
end

--Get density similarly
local function get_density(ni, ni3d, y, size, biome)
    local density_below = y+terrain_data3d[biome][ni3d]-terrain_data[biome][ni]-1
    local density = y+terrain_data3d[biome][ni3d+size]-terrain_data[biome][ni]
    local density_above = y+terrain_data3d[biome][ni3d+size*2]-terrain_data[biome][ni]+1
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
            or (defs.type == "top" and density_below <= 0 and density > 0) then
                return defs.decor_id, (defs.max_param2 and param2_rand:next(1, defs.max_param2))
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
                    local biome, bdefs = get_biome_data(ni, pos)
                    local density_below, density, density_above = get_density(ni, ni3d, y, size, biome)
                    
                    local id, param2 = place_decors(ni3d, biome, density_below, density, density_above, param2_rand)
                    if id then
                        vm_data[vi] = id
                        if param2 then param2_data[vi] = param2 end
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
    vm:calc_lighting()
    vm:write_to_map()
    vm:update_liquids()
end)