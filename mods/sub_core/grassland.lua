--Grassy Plateau and Grassy Plateau Caves biomes
sub_core.register_biome("sub_core:grassland", {
    name = "Grassland",
    node_top = "sub_core:sand",
    node_stone = "sub_core:sandstone",
    node_water = "sub_core:grassland_water",
    heat_point = 40,
    humidity_point = 30,
    dist_point = 400,
    noise = {
        offset = -80,
        scale = 20,
        spread = {x=200, y=200, z=200},
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.0
    },
    noise3d = {
        offset = 0,
        scale = 10,
        spread = {x=50, y=50, z=50},
        octaves = 2,
        persistence = 0.5,
        lacunarity = 2.0
    }
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
    decor = "sub_core:limestone_outcrop_spawner"
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:grassland",
    fill_ratio = 0.002,
    decor = "sub_core:sandstone_outcrop_spawner"
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.0004,
    decor = "sub_core:quartz_outcrop",
    param2 = 1
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.001,
    max_param2 = 4,
    decor = "sub_core:salvage1"
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