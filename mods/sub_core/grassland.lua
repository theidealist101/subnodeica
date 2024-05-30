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

--Grass covering the floor in blob shapes
minetest.register_node("sub_core:blood_grass", sub_core.add_water_physics({
    description = "Blood Grass",
    drawtype = "plantlike",
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

--Various other decorations
minetest.register_node(
    "sub_core:grassland_limestone",
    sub_core.add_water_physics(sub_core.limestone_defs, "sub_core:grassland_water")
)

minetest.register_node(
    "sub_core:grassland_sandstone",
    sub_core.add_water_physics(sub_core.sandstone_defs, "sub_core:grassland_water")
)

minetest.register_node(
    "sub_core:grassland_quartz",
    sub_core.add_water_physics(sub_core.quartz_defs, "sub_core:grassland_water")
)

minetest.register_node(
    "sub_core:grassland_salvage1",
    sub_core.add_water_physics(sub_core.salvage1_defs, "sub_core:grassland_water")
)

sub_core.register_spawner("sub_core:grassland_limestone", "sub_core:sandstone", "sub_core:sandstone", {
    description = "Grassland Limestone Spawner",
    tiles = {"default_sandstone.png"}
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:grassland",
    fill_ratio = 0.001,
    decor = "sub_core:grassland_limestone_spawner"
})

sub_core.register_spawner("sub_core:grassland_sandstone", "sub_core:sandstone", "sub_core:sandstone", {
    description = "Grassland Sandstone Spawner",
    tiles = {"default_sandstone.png"}
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:grassland",
    fill_ratio = 0.002,
    decor = "sub_core:grassland_sandstone_spawner"
})
sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.0004,
    decor = "sub_core:grassland_quartz",
    param2 = 1
})

sub_core.register_decor({
    biome = "sub_core:grassland",
    fill_ratio = 0.001,
    max_param2 = 4,
    decor = "sub_core:grassland_salvage1"
})