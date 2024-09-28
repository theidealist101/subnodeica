--Seaglide, not exactly a vehicle but can be held to go double the speed
minetest.register_tool("sub_vehicles:seaglide", {
    description = "Seaglide",
    inventory_image = "sub_vehicles_seaglide.png",
    _equip = "wield",
    _on_equip = function (player, itemstack)
        itemstack:get_meta():set_int("monoid", sub_core.swim_monoid:add_change(player, 2.5))
    end,
    _equip_tick = function (player, itemstack, dtime)
        minetest.log(dump(itemstack:get_meta():get_int("monoid")))
        if not minetest.registered_nodes[minetest.get_node(vector.round(player:get_pos())).name].liquid_move_physics or player:get_attach() then return end
        local wear = itemstack:get_wear()
        wear = math.min(math.max(math.round(wear+dtime*172.5), 0), 65535) --172.5 is approximately 65535/380
        if wear >= 65535 then itemstack:get_definition()._on_unequip(player, itemstack) end
        itemstack:set_wear(wear)
    end,
    _on_unequip = function (player, itemstack)
        sub_core.swim_monoid:del_change(player, itemstack:get_meta():get_int("monoid"))
    end,
    on_use = sub_crafts.switch_battery
})

sub_crafts.register_craft({
    category = "deployables",
    output = {"sub_vehicles:seaglide"},
    recipe = {"sub_crafts:battery", "sub_crafts:lubricant", "sub_crafts:copper_wire", "sub_core:titanium"}
})