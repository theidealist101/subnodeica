sub_bases = {}

--Register information pertaining to an exterior or interior piece
sub_bases.registered_pieces = {}

function sub_bases.register_piece(name, defs)
    defs.size = defs.size or vector.zero()
    defs.schems = defs.schems or {}
    defs.schems.fixed = defs.schems.fixed
    sub_bases.registered_pieces[name] = defs
    sub_crafts.register_craft({
        type = "builder",
        category = defs.category,
        subcategory = defs.subcategory,
        output = name,
        output_icon = defs.icon,
        recipe = defs.recipe
    })
end

local path = minetest.get_modpath("sub_bases").."/"
dofile(path.."builder.lua")
dofile(path.."nodes.lua")
dofile(path.."pieces.lua")