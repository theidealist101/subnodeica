--Homepage: inventory view
local inventory_formspec = [[
    list[current_player;head;10.75,2;1,1;]
    list[current_player;body;10.75,4.5;1,1;]
    list[current_player;feet;10.75,7;1,1;]
    list[current_player;tank;9,3.25;1,1;]
    list[current_player;hands;12.5,3.25;1,1;]
    list[current_player;chips;9,5.75;1,1;]
    list[current_player;chips;12.5,5.75;1,1;1]
]]

sfinv.register_page("sub_inv:inventory", {
    title = "Inventory",
    get = function (self, player, context)
        return sub_inv.make_formspec(player, context, inventory_formspec, true)
    end
})

--Get rid of default page
sfinv.override_page("sfinv:crafting", {is_in_nav=function() end})

function sfinv.get_homepage_name(player)
    return "sub_inv:inventory"
end

--Make sure inventory is the right size
minetest.register_on_joinplayer(function(player)
    local inv = player:get_inventory()
    inv:set_size("main", 48)
    for i, name in ipairs({"head", "body", "feet", "tank", "hands"}) do
        inv:set_size(name, 1)
    end
    inv:set_size("chips", 2)
    player:hud_set_hotbar_itemcount(6)
end)

--Only allow certain items to be equipped
minetest.register_allow_player_inventory_action(function(player, action, inv, inv_info)
    local list, item
    if action == "put" then
        list = inv_info.listname
        item = inv_info.stack
    elseif action == "move" then
        list = inv_info.to_list
        item = inv:get_stack(inv_info.from_list, inv_info.from_index)
    else return end
    local defs = item:get_definition()
    for i, name in ipairs({"head", "body", "feet", "tank", "hands", "chips"}) do
        if list == name and defs._equip ~= name then return 0 end
    end
    return 1
end)

--Add actions for when equippable items are added or removed
minetest.register_on_player_inventory_action(function(player, action, inv, inv_info)
    local old_list, new_list, item
    if action == "put" then
        new_list = inv_info.listname
        item = inv_info.stack
    elseif action == "move" then
        old_list = inv_info.from_list
        new_list = inv_info.to_list
        item = inv:get_stack(inv_info.to_list, inv_info.to_index)
    elseif action == "take" then
        old_list = inv_info.listname
        item = inv_info.stack
    else return end --in case something weird happens
    local defs = item:get_definition()
    for i, name in ipairs({"head", "body", "feet", "tank", "hands", "chips"}) do
        if old_list == name and defs._on_unequip then defs._on_unequip(player) end
        if new_list == name and defs._on_equip then defs._on_equip(player) end
    end
end)