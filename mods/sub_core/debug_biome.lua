--Debug biome to be used for mapgen testing only
sub_core.register_biome("sub_core:debug1", {
    name = "Debug1",
    node_water_surface = "sub_core:stone",
    height_point = -50
})

sub_core.register_biome("sub_core:debug2", {
    name = "Debug2",
    node_water_surface = "sub_core:sand",
    height_point = -100
})

sub_core.register_biome("sub_core:debug3", {
    name = "Debug3",
    node_water_surface = "sub_core:stone",
    height_point = -300
})

sub_core.register_biome("sub_core:debug4", {
    name = "Debug4",
    node_water_surface = "sub_core:sand",
    node_stone = "air",
    height_point = -600
})