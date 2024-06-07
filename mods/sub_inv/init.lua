sub_inv = {}

--Make sure inventory is the right size
minetest.register_on_joinplayer(function(player)
    player:get_inventory():set_size("main", 48)
    player:hud_set_hotbar_itemcount(6)
end)

--Custom inventory layout
function sub_inv.make_formspec(player, context, content, show_inv, size)
    return table.concat({
        "formspec_version[8]",
        size or "size[15.25,10.25]",
        sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
        show_inv and "list[current_player;main;0.25,0.25;6,8;]" or "",
        content
    }, "")
end

local path = minetest.get_modpath("sub_inv").."/"
dofile(path.."inventory.lua")
dofile(path.."databank.lua")