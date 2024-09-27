--Seaglide, not exactly a vehicle but can be held to go double the speed
minetest.register_tool("sub_vehicles:seaglide", {
    description = "Seaglide",
    inventory_image = "sub_vehicles_seaglide.png",
    _equip = "wield",
    _on_equip = function (player, itemstack)
        itemstack:get_meta():set_int("monoid", sub_core.swim_monoid:add_change(player, 2.5))
    end,
    _on_unequip = function (player, itemstack)
        sub_core.swim_monoid:del_change(player, itemstack:get_meta():get_int("monoid"))
    end
})

sub_crafts.register_craft({
    category = "deployables",
    output = {"sub_vehicles:seaglide"},
    recipe = {"sub_crafts:battery", "sub_crafts:lubricant", "sub_crafts:copper_wire", "sub_core:titanium"}
})