--Titanium ingot, used for mid-game construction and plasteel
minetest.register_craftitem("sub_crafts:titanium_ingot", {
    description = "Titanium Ingot",
    inventory_image = "default_tin_ingot.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_crafts:titanium_ingot"},
    recipe = {"sub_core:titanium 10"}
})

--Silicone rubber, used for crafting equipment including the survival knife
minetest.register_craftitem("sub_crafts:rubber", {
    description = "Rubber",
    inventory_image = "sub_crafts_rubber.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_crafts:rubber 2"},
    recipe = {"sub_core:creepvine_seeds"}
})

--Lubricant, used in construction of most vehicles and some base pieces
minetest.register_craftitem("sub_crafts:lubricant", {
    description = "Lubricant",
    inventory_image = "sub_crafts_lubricant.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_crafts:lubricant"},
    recipe = {"sub_core:creepvine_seeds"}
})

--Copper wire, essential for electronics
minetest.register_craftitem("sub_crafts:copper_wire", {
    description = "Copper Wire",
    inventory_image = "sub_crafts_copper_wire.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "electronics",
    output = {"sub_crafts:copper_wire"},
    recipe = {"sub_core:copper 2"}
})

--Battery, essential for tools
minetest.register_craftitem("sub_crafts:battery", {
    description = "Battery",
    inventory_image = "sub_crafts_battery.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "electronics",
    output = {"sub_crafts:battery"},
    recipe = {"sub_core:item_acidshroom 2", "sub_core:copper"}
})

--Filtered water, early-game source of water
minetest.register_craftitem("sub_crafts:filtered_water", {
    description = "Filtered Water",
    inventory_image = "sub_crafts_filtered_water.png"
})

sub_crafts.register_craft({
    category = "sustenance",
    subcategory = "water",
    output = {"sub_crafts:filtered_water"},
    recipe = {"sub_mobs:item_bladderfish"}
})