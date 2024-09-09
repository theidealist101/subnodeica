--Debug biome to be used for mapgen testing only
sub_core.register_biome("sub_core:debug", {
    name = "Debug",
    node_water_surface = "sub_core:stone",
    heat_point = 0,
    humidity_point = 0,
    dist_point = 0,
    noise = {
        offset = -30,
        scale = 15,
        spread = {x=100, y=100, z=100},
        octaves = 1,
        persistence = 0.5,
        lacunarity = 2.0
    },
    noise3d = {
        offset = 0,
        scale = 10,
        spread = {x=20, y=20, z=20},
        octaves = 1,
        persistence = 0.5,
        lacunarity = 2.0
    }
})