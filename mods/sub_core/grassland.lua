--Grassy Plateau and Grassy Plateau Caves biomes
sub_core.register_biome("sub_core:grassland", {
    name = "Grassland",
    node_top = "sub_core:sand",
    node_water = "sub_core:grassland_water",
    height_point = -100,
    heat_point = 50,
    cave_level = -4
})

sub_core.register_water("sub_core:grassland_water", {
    description = "Grassland Water",
    color = {r=140, g=180, b=255},
    tint = {r=100, g=130, b=200, a=100},
    fog = {
        fog_distance = 150,
        fog_start = 0.4,
        fog_color = {r=100, g=130, b=200}
    }
})

--Noise function used for placing rarer plants in clumps
local decor_noise = {
    offset = -0.9,
    scale = 1,
    spread = {x=16, y=32, z=16},
    octaves = 5,
    persistence = 0.5,
    lacunarity = 2.0
}

--Various other decorations
sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.05,
    decor = "sub_core:veined_nettle",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.05,
    decor = "sub_core:writhing_weed",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.05,
    decor = "sub_core:furled_papyrus",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.05,
    decor = "sub_core:redwort",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.05,
    decor = "sub_core:violet_beau",
    noise = decor_noise
})

sub_core.register_decor({
    type = "surface",
    biome = "sub_core:grassland",
    fill_ratio = 0.7,
    decor = "sub_core:sand_with_lichen",
    noise = decor_noise
})

sub_core.register_decor({
    type = "surface",
    biome = "sub_core:grassland",
    fill_ratio = 0.01,
    decor = "sub_core:sandstone"
})

for i = 1, 4 do
    sub_core.register_decor({
        biome = "sub_core:grassland",
        fill_ratio = 0.1,
        decor = "sub_core:acidshroom"..i,
        max_param2 = 4,
        noise = decor_noise
    })
end

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:grassland",
    fill_ratio = 0.001,
    decor = "sub_core:limestone_outcrop_stone_spawner"
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:grassland",
    fill_ratio = 0.002,
    decor = "sub_core:sandstone_outcrop_stone_spawner"
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.0004,
    decor = "sub_core:quartz_outcrop",
    param2 = 1
})

sub_core.register_decor({
    type = "surface",
    in_cave = true,
    not_surface = true,
    biome = "sub_core:grassland",
    fill_ratio = 0.6,
    decor = "sub_core:sandstone"
})

sub_core.register_decor({
    type = "underground",
    in_cave = true,
    not_surface = true,
    biome = "sub_core:grassland",
    fill_ratio = 0.1,
    decor = "sub_core:limestone_outcrop_stone_spawner"
})

sub_core.register_decor({
    type = "underground",
    in_cave = true,
    not_surface = true,
    biome = "sub_core:grassland",
    fill_ratio = 0.08,
    decor = "sub_core:sandstone_outcrop_stone_spawner"
})

sub_core.register_decor({
    in_cave = true,
    not_surface = true,
    biome = "sub_core:grassland",
    fill_ratio = 0.01,
    decor = "sub_core:quartz_outcrop",
    param2 = 1
})

sub_core.register_decor({
    in_cave = true,
    not_surface = true,
    type = "bottom",
    biome = "sub_core:grassland",
    fill_ratio = 0.1,
    decor = "sub_core:drooping_stinger"
})

sub_core.register_decor({
    in_cave = true,
    not_surface = true,
    biome = "sub_core:grassland",
    fill_ratio = 0.004,
    decor = "sub_core:regress_shell"
})

sub_core.register_decor({
    in_cave = true,
    not_surface = true,
    biome = "sub_core:grassland",
    fill_ratio = 0.004,
    decor = "sub_core:rouge_cradle"
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.001,
    max_param2 = 4,
    decor = "sub_core:salvage1"
})

sub_core.register_carver({
    biome = "sub_core:grassland",
    chance = 0.2,
    func = sub_core.cave_carver
})

--Grass covering the floor in blob shapes
minetest.register_node("sub_core:blood_grass", sub_core.add_water_physics({
    description = "Blood Grass",
    drawtype = "plantlike",
    paramtype2 = "meshoptions",
    tiles = {"sub_core_blood_grass.png"},
    inventory_image = "sub_core_blood_grass.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}
    },
    walkable = false,
    pointable = false,
    buildable_to = true,
    groups = {attached_node=1}
}, "sub_core:grassland_water"))

minetest.register_node("sub_core:pink_blood_grass", sub_core.add_water_physics({
    description = "Pink Blood Grass",
    drawtype = "plantlike",
    paramtype2 = "meshoptions",
    tiles = {"sub_core_pink_blood_grass.png"},
    inventory_image = "sub_core_pink_blood_grass.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375}
    },
    walkable = false,
    pointable = false,
    buildable_to = true,
    groups = {attached_node=1}
}, "sub_core:grassland_water"))

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.8,
    param2 = 8,
    decor = "sub_core:blood_grass",
    noise = {
        offset = 0,
        scale = 1,
        spread = {x=50, y=100, z=50},
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.0
    }
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.1,
    param2 = 8,
    decor = "sub_core:pink_blood_grass",
    noise = {
        offset = -0.2,
        scale = 1,
        spread = {x=50, y=100, z=50},
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.0
    }
})

--Pillar carvers, the funny little stool shapes which make the grasslands distinctive
local sqrt, cos, hypot, min = math.sqrt, math.cos, math.hypot, math.min
local inv2 = 1/sqrt(2)

local function get_pillar_density(pos, start_pos, height, width)
    local width_sq = width^2
    local y_diff = pos.y-start_pos.y
    local x_diff = hypot(pos.x-start_pos.x, pos.z-start_pos.z)
    if x_diff > width or y_diff < -width*0.5 or y_diff > height+width*0.25 then return 0 end
    local w = y_diff < 0 and sqrt(width_sq*0.5-y_diff^2)
        or y_diff < height and 2*width*((y_diff/height-0.43)^2+0.17)
        or sqrt(width_sq-16*(y_diff-height)^2)
    return min(0, x_diff-w)
end

local function pillar_carver(start_pos, minp, maxp, random)
    local height = random:next(15, 25)
    local width = height*0.1*random:next(3, 5)
    if minp.x+width > start_pos.x or start_pos.x > maxp.x-width
    or minp.y+width*0.5 > start_pos.y or start_pos.y > maxp.y-height-width*0.25
    or minp.z+width > start_pos.z or start_pos.z > maxp.z-width then return end

    if random:next(0, 4) == 0 then
        local height2 = random:next(10, 20)
        local width2 = height2*0.1*random:next(3, 5)
        if start_pos.y < maxp.y-height-height2-width2*0.25 then
            local start_pos2 = start_pos+vector.new(0, height, 0)
            return function (pos)
                return get_pillar_density(pos, start_pos, height, width)+get_pillar_density(pos, start_pos2, height2, width2)
            end
        end
    end
    return function (pos)
        return get_pillar_density(pos, start_pos, height, width)
    end
end

sub_core.register_carver({
    biome = "sub_core:grassland",
    chance = 1,
    func = pillar_carver
})