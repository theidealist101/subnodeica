--Crater Edge biome
sub_core.register_biome("sub_core:void", {
    name = "Void",
    not_generated = true,
    node_top = "sub_core:void_water",
    node_stone = "sub_core:void_water",
    node_water = "sub_core:void_water",
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

sub_core.biome_default = "sub_core:void"

sub_core.register_water("sub_core:void_water", {
    description = "Void Water",
    color = {r=30, g=30, b=90},
    tint = {r=0, g=0, b=20, a=200},
    fog = {
        fog_distance = 100,
        fog_start = 0,
        fog_color = {r=0, g=0, b=10}
    }
})