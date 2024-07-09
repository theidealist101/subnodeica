--Aliases, necessary because I can't be bothered to rebuild the schematic
minetest.register_alias("sub_core:titanium_block", "sub_bases:titanium_block")
minetest.register_alias("sub_core:dark_titanium_block", "sub_bases:dark_titanium_block")
minetest.register_alias("sub_core:black_titanium_block", "sub_bases:black_titanium_block")
minetest.register_alias("sub_initial_stuff:flotation_block", "sub_bases:flotation_block")
minetest.register_alias("sub_initial_stuff:striped_flotation_block", "sub_bases:striped_flotation_block")
minetest.register_alias("sub_initial_stuff:light", "sub_bases:light")
minetest.register_alias("sub_initial_stuff:ladder", "sub_bases:ladder")
minetest.register_alias("sub_initial_stuff:lifepod_ladder", "sub_bases:lifepod_ladder")
minetest.register_alias("sub_initial_stuff:hatch", "sub_bases:hatch")

--Place lifepod schematic on spawn
minetest.register_on_newplayer(function(player)
    player:set_pos(vector.new(0, 1, -1))
    minetest.place_schematic(vector.zero(), minetest.get_modpath("sub_initial_stuff").."/schems/lifepod5.mts", nil, nil, true, "place_center_x, place_center_z")
end)

--Place waypoint on first load
sub_nav.register_on_load(function()
    sub_nav.set_waypoint(vector.new(0, 1, 0), {
        name = "Lifepod 5",
        image = "waypoint_lifepod5.png",
        dist = 10
    })
end)