--Waterproof locker, a deployable with a small inventory
minetest.register_craftitem("sub_crafts:item_water_locker", {
    description = "Waterproof Locker",
    inventory_image = "sub_crafts_item_water_locker.png",
    _hovertext = "Place Waterproof Locker (RMB)"
})

sub_crafts.register_craft({
    category = "deployables",
    output = {"sub_crafts:item_water_locker"},
    recipe = {"sub_core:titanium 4"}
})