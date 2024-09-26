--Basic structural nodes
minetest.register_node("sub_bases:titanium_block", {
    description = "Titanium Block",
    tiles = {"sub_bases_titanium_block.png"}
})

minetest.register_node("sub_bases:dark_titanium_block", {
    description = "Dark Titanium Block",
    tiles = {"sub_bases_dark_titanium_block.png"}
})

minetest.register_node("sub_bases:black_titanium_block", {
    description = "Black Titanium Block",
    tiles = {"sub_bases_black_titanium_block.png"}
})

minetest.register_node("sub_bases:flotation_block", {
    description = "Flotation Block",
    tiles = {"sub_bases_flotation_block.png"}
})

minetest.register_node("sub_bases:striped_flotation_block", {
    description = "Striped Flotation Block",
    tiles = {
        "sub_bases_striped_flotation_block.png",
        "sub_bases_striped_flotation_block.png",
        "sub_bases_flotation_block.png",
        "sub_bases_flotation_block.png",
        "sub_bases_striped_flotation_block.png",
        "sub_bases_striped_flotation_block.png"
    },
    paramtype2 = "4dir"
})

minetest.register_node("sub_bases:light", {
    description = "Light Block",
    drawtype = "signlike",
    tiles = {"sub_bases_light.png"},
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    light_source = 14
})

--Devices, modules etc.
minetest.register_node("sub_bases:ladder", {
    description = "Ladder",
    drawtype = "signlike",
    tiles = {"sub_bases_ladder.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}
    },
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    climbable = true,
    _hovertext = "Ladder (climbable)"
})

minetest.register_node("sub_bases:lifepod_ladder", {
    description = "Lifepod Ladder",
    drawtype = "signlike",
    tiles = {"sub_bases_lifepod_ladder.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}
    },
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    climbable = true,
    _hovertext = "Ladder (climbable)"
})

local function hatch_on_rightclick(pos, _, clicker, _, pointed)
    if not pointed.type == "node" then return end
    local dir = pos-pointed.above
    if dir == vector.new(0, -1, 0) then dir = vector.new(0, -2, 0) end
    dir.y = dir.y-0.5
    clicker:set_pos(pos+dir)
end

minetest.register_node("sub_bases:hatch", {
    description = "Hatch",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5} --imitates glasslike while being wallmounted
    },
    tiles = {
        "sub_bases_hatch.png",
        "sub_bases_hatch.png",
        "blank.png",
        "blank.png",
        "blank.png",
        "blank.png"
    },
    use_texture_alpha = "clip",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    on_rightclick = hatch_on_rightclick,
    _hovertext = "Use Hatch (RMB)"
})