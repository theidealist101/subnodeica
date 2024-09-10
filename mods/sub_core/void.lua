--Crater Edge biome
sub_core.register_biome("sub_core:void", {
    name = "Void",
    node_top = "sub_core:void_water",
    node_stone = "sub_core:void_water",
    node_water = "sub_core:void_water",
    height_point = -500
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