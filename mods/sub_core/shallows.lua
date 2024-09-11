--Safe Shallows and Safe Shallows Caves biomes
sub_core.register_biome("sub_core:shallows", {
    name = "Shallows",
    node_top = "sub_core:sand",
    node_stone = "sub_core:sandstone",
    node_water = "sub_core:shallows_water",
    height_point = -40,
    heat_point = 55
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
sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.05,
    decor = "sub_core:veined_nettle",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.1,
    decor = "sub_core:writhing_weed",
    noise = decor_noise
})

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.05,
    decor = "sub_core:blue_palm",
    noise = decor_noise
})

sub_core.register_decor({
    type = "surface",
    biome = "sub_core:shallows",
    fill_ratio = 0.7,
    decor = "sub_core:sand_with_lichen",
    noise = decor_noise
})

sub_core.register_decor({
    type = "surface",
    biome = "sub_core:shallows",
    fill_ratio = 0.02,
    decor = "sub_core:sandstone"
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:shallows",
    fill_ratio = 0.7,
    decor = "sub_core:sandstone_with_scales",
    noise = {
        offset = 0,
        scale = 1,
        spread = {x=4, y=8, z=4},
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.0
    }
})

for i = 1, 4 do
    sub_core.register_decor({
        biome = "sub_core:shallows",
        fill_ratio = 0.1,
        decor = "sub_core:acidshroom"..i,
        max_param2 = 4,
        noise = decor_noise
    })
end

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:shallows",
    fill_ratio = 0.8,
    decor = "sub_core:table_coral_spawner",
    noise = {
        offset = -0.5,
        scale = 1,
        spread = {x=4, y=64, z=4},
        octaves = 3,
        persistence = 0.5,
        lacunarity = 2.0
    }
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:shallows",
    fill_ratio = 0.002,
    decor = "sub_core:limestone_outcrop_spawner"
})

sub_core.register_schem({
    type = "surface",
    biome = "sub_core:shallows",
    fill_ratio = 0.0005,
    radius = 5,
    schem = minetest.get_modpath("sub_core").."/schems/coral_tube.mts",
})

sub_core.register_decor({
    type = "cave_top",
    biome = "sub_core:shallows",
    fill_ratio = 0.01,
    decor = "sub_core:brain_coral"
})

sub_core.register_decor({
    biome = "sub_core:shallows",
    fill_ratio = 0.001,
    max_param2 = 4,
    decor = "sub_core:salvage1"
})