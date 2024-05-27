minetest.register_node("sub_initial_stuff:flotation_block", {
    description = "Flotation Block",
    tiles = {"sub_initial_stuff_flotation_block.png"}
})

minetest.register_node("sub_initial_stuff:striped_flotation_block", {
    description = "Striped Flotation Block",
    tiles = {
        "sub_initial_stuff_striped_flotation_block.png",
        "sub_initial_stuff_striped_flotation_block.png",
        "sub_initial_stuff_flotation_block.png",
        "sub_initial_stuff_flotation_block.png",
        "sub_initial_stuff_striped_flotation_block.png",
        "sub_initial_stuff_striped_flotation_block.png"
    },
    paramtype2 = "4dir"
})

minetest.register_node("sub_initial_stuff:light", {
    description = "Light Block",
    drawtype = "signlike",
    tiles = {"sub_initial_stuff_light.png"},
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    buildable_to = true,
    light_source = 15
})

minetest.register_on_newplayer(function(player)
    player:set_pos(vector.new(0, 2, -1))
    minetest.place_schematic(vector.new(0, 1, 0), minetest.get_modpath("sub_initial_stuff").."/schems/lifepod5.mts", nil, nil, true, "place_center_x, place_center_z")
end)