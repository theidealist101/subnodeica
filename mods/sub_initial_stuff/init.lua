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
    light_source = 14
})

minetest.register_node("sub_initial_stuff:ladder", {
    description = "Ladder",
    drawtype = "signlike",
    tiles = {"sub_initial_stuff_ladder.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}
    },
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    climbable = true,
})

minetest.register_node("sub_initial_stuff:lifepod_ladder", {
    description = "Lifepod Ladder",
    drawtype = "signlike",
    tiles = {"sub_initial_stuff_lifepod_ladder.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}
    },
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    climbable = true,
})

minetest.register_on_newplayer(function(player)
    player:set_pos(vector.new(0, 1, -1))
    minetest.place_schematic(vector.zero(), minetest.get_modpath("sub_initial_stuff").."/schems/lifepod5.mts", nil, nil, true, "place_center_x, place_center_z")
end)

sub_nav.register_on_load(function()
    sub_nav.set_waypoint(vector.new(0, 1, 0), {
        name = "Lifepod 5",
        image = "waypoint_lifepod5.png",
        dist = 10
    })
end)