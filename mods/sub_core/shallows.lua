--Safe Shallows and Safe Shallows Caves biomes
sub_core.register_biome("sub_core:shallows", {
    name = "Shallows",
    node_top = "sub_core:sand",
    node_stone = "sub_core:sandstone",
    node_water = "sub_core:shallows_water",
    heat_point = 60,
    humidity_point = 60,
    dist_point = 0,
    noise = {
        offset = -20,
        scale = 5,
        spread = {x=100, y=100, z=100},
        octaves = 4,
        persistence = 0.5,
        lacunarity = 2.0
    },
    noise3d = {
        offset = 0,
        scale = 12,
        spread = {x=20, y=20, z=20},
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.0
    }
})

sub_core.register_water("sub_core:shallows_water", {
    description = "Shallows Water",
    color = {r=120, g=180, b=255},
    tint = {r=30, g=60, b=90, a=100},
    fog = {
        fog_distance = 100,
        fog_start = 0.3,
        fog_color = {r=120, g=180, b=255}
    }
})

--Sparse bits of grass
minetest.register_node("sub_core:shallows_grass", sub_core.add_water_physics({
    description = "Shallows Grass",
    drawtype = "plantlike",
    tiles = {"default_marram_grass_1.png"},
    inventory_image = "default_marram_grass_1.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, -0.125, 0.25}
    },
    walkable = false,
    pointable = false,
    buildable_to = true,
    groups = {attached_node=1}
}, "sub_core:shallows_water"))

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.1,
    decor = "sub_core:shallows_grass"
})

--Noise function used for placing rarer plants in clumps
local decor_noise = {
    offset = -0.7,
    scale = 1,
    spread = {x=4, y=8, z=4},
    octaves = 3,
    persistence = 0.5,
    lacunarity = 2.0
}

--Various other plants and corals
minetest.register_node(
    "sub_core:shallows_veined_nettle",
    sub_core.add_water_physics(sub_core.veined_nettle_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_writhing_weed",
    sub_core.add_water_physics(sub_core.writhing_weed_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_blue_palm",
    sub_core.add_water_physics(sub_core.blue_palm_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_acidshroom1",
    sub_core.add_water_physics(sub_core.acidshroom1_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_acidshroom2",
    sub_core.add_water_physics(sub_core.acidshroom2_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_acidshroom3",
    sub_core.add_water_physics(sub_core.acidshroom3_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_acidshroom4",
    sub_core.add_water_physics(sub_core.acidshroom4_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_table_coral",
    sub_core.add_water_physics(sub_core.table_coral_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_limestone",
    sub_core.add_water_physics(sub_core.limestone_defs, "sub_core:shallows_water")
)

minetest.register_node(
    "sub_core:shallows_salvage1",
    sub_core.add_water_physics(sub_core.salvage1_defs, "sub_core:shallows_water")
)

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.05,
    decor = "sub_core:shallows_veined_nettle",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.1,
    decor = "sub_core:shallows_writhing_weed",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.05,
    decor = "sub_core:shallows_blue_palm",
    noise = decor_noise
})

sub_core.register_decor({
    type = "surface",
    biome = "sub_core:shallows",
    fill_ratio = 0.7,
    decor = "sub_core:sand_with_lichen",
    noise = decor_noise
})

for i = 1, 4 do
    sub_core.register_decor({
        biome = "sub_core:shallows",
        fill_ratio = 0.1,
        decor = "sub_core:shallows_acidshroom"..i,
        max_param2 = 4,
        noise = decor_noise
    })
end

sub_core.register_spawner("sub_core:shallows_table_coral", "sub_core:sandstone_with_lichen", "sub_core:sandstone", {
    description = "Shallows Table Coral Spawner",
    tiles = {"default_sandstone.png^sub_core_lichen.png"}
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:shallows",
    fill_ratio = 0.8,
    decor = "sub_core:shallows_table_coral_spawner",
    noise = {
        offset = -0.5,
        scale = 1,
        spread = {x=4, y=64, z=4},
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.0
    }
})

sub_core.register_spawner("sub_core:shallows_limestone", "sub_core:sandstone", "sub_core:sandstone", {
    description = "Shallows Limestone Spawner",
    tiles = {"default_sandstone.png"}
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:shallows",
    fill_ratio = 0.002,
    decor = "sub_core:shallows_limestone_spawner"
})

sub_core.register_schem({
    type = "surface",
    biome = "sub_core:shallows",
    fill_ratio = 0.0005,
    radius = 5,
    schem = minetest.get_modpath("sub_core").."/schems/coral_tube.mts",
})

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.001,
    max_param2 = 4,
    decor = "sub_core:shallows_salvage1"
})