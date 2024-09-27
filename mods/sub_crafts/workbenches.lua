--Fabricator, interior module (when I get round to adding seabases), used for most crafting
minetest.register_node("sub_crafts:fabricator", {
    description = "Fabricator",
    drawtype = "mesh",
    mesh = "fabricator.obj",
    tiles = {"fabricator.png"},
    use_texture_alpha = "opaque",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, 0.25, 0.375, 0.5, 0.5}
    },
    walkable = false,
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    on_rightclick = function (pos, node, user)
        minetest.show_formspec(user:get_player_name(), "sub_crafts:fabricator_formspec", sub_crafts.get_formspec(user, "fabricator"))
    end,
    _hovertext = "Use Fabricator (RMB)"
})

local creative = minetest.settings:get_bool("creative_mode")

--Function for navigating the fabricator menu and crafting items
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "sub_crafts:fabricator_formspec" then return end
    local playername = player:get_player_name()
    local inv = player:get_inventory()
    for name, value in pairs(fields) do
        if value then
            if name == "quit" then return end
            local names = string.split(name, "|")
            --test if it can be a recipe
            local names2 = table.copy(names)
            table.insert(names2, 1, table.remove(names2, #names2))
            local recipe = sub_crafts.get_recipe("fabricator", unpack(names2))
            if recipe and sub_crafts.can_do_recipe(inv, recipe.recipe) then
                if not creative then
                    for i, item in ipairs(recipe.recipe) do
                        inv:remove_item("main", ItemStack(item))
                    end
                end
                for i, item in ipairs(recipe.output) do
                    item = ItemStack(item)
                    for _, func in ipairs(sub_crafts.registered_on_crafts) do
                        item = func(item, player) or item
                    end
                    inv:add_item("main", item)
                end
                table.remove(names, #names)
            end
            --show the corresponding menu
            local formspec = sub_crafts.get_formspec(player, "fabricator", unpack(names))
            minetest.show_formspec(playername, formname, formspec)
            return
        end
    end
end)

--Medical kit fabricator, generates a medkit every 10 minutes without needing any power
minetest.register_node("sub_crafts:medkit_fabricator", {
    description = "Medical Kit Fabricator",
    drawtype = "mesh",
    mesh = "medkit_fabricator.obj",
    tiles = {"medkit_fabricator.png"},
    use_texture_alpha = "opaque",
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.375, 0.375, 0.25, 0.375, 0.5}
    },
    walkable = false,
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    on_rightclick = function (pos, node, user, itemstack)
        local meta = minetest.get_meta(pos)
        local now = minetest.get_gametime()
        local last_used = meta:get("last_used") or -600
        if now-last_used < 600 then return end
        meta:set_int("last_used", now)
        return sub_core.give_item("sub_crafts:medkit")(pos, node, user, itemstack)
    end,
    _hovertext = function (itemstack, user, pointed)
        local meta = minetest.get_meta(pointed.under)
        local now = minetest.get_gametime()
        local last_used = meta:get("last_used") or -600
        if now-last_used < 600 then
            return "Medical Kit Fabricator ("..math.floor(math.min(now-last_used, 600)/6).."%)"
        else
            return "Collect First Aid Kit (RMB)"
        end
    end
})