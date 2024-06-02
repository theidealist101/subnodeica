sub_inv = {}

--Make sure inventory is the right size
minetest.register_on_joinplayer(function(player)
    player:get_inventory():set_size("main", 48)
    player:hud_set_hotbar_itemcount(6)
end)

--Custom inventory layout
function sub_inv.make_formspec(player, context, content, show_inv, size)
    return table.concat({
        size or "size[12,7.775]",
        sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
        show_inv and "list[current_player;main;0,0;6,8;]" or "",
        content
    }, "")
end

--Homepage: inventory view
sfinv.register_page("sub_inv:inventory", {
    title = "Inventory",
    get = function (self, player, context)
        return sub_inv.make_formspec(player, context, "", true)
        --TODO: add equips, items taking up several slots, automatic item sorting etc. to emulate Subnautica inventory
    end
})

--Get rid of default page
sfinv.override_page("sfinv:crafting", {is_in_nav=function() end})

function sfinv.get_homepage_name(player)
    return "sub_inv:inventory"
end