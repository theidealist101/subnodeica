--Titanium crafted from metal salvage
sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_core:titanium", "sub_core:titanium", "sub_core:titanium", "sub_core:titanium"},
    recipe = {"sub_core:salvage"}
})

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

--Fiber mesh, important for medkits and some equipment
minetest.register_craftitem("sub_crafts:fiber_mesh", {
    description = "Fiber Mesh",
    inventory_image = "sub_crafts_fiber_mesh.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_crafts:fiber_mesh"},
    recipe = {"sub_core:creepvine_sample 2"}
})

--Silicone rubber, used for crafting equipment including the survival knife
minetest.register_craftitem("sub_crafts:rubber", {
    description = "Rubber",
    inventory_image = "sub_crafts_rubber.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_crafts:rubber", "sub_crafts:rubber"},
    recipe = {"sub_core:creepvine_seeds"}
})

--Glass, useful for some tools and decorative base pieces
minetest.register_craftitem("sub_crafts:glass", {
    description = "Glass",
    inventory_image = "vessels_glass_fragments.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_crafts:glass"},
    recipe = {"sub_core:quartz 2"}
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

--Computer chip, used for many tools and upgrades
minetest.register_craftitem("sub_crafts:computer_chip", {
    description = "Computer Chip",
    inventory_image = "sub_crafts_computer_chip.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "electronics",
    output = {"sub_crafts:computer_chip"},
    recipe = {"sub_core:table_coral_sample 2", "sub_core:gold", "sub_crafts:copper_wire"}
})

--Wiring kit, used for various tools and modules
minetest.register_craftitem("sub_crafts:wiring_kit", {
    description = "Wiring Kit",
    inventory_image = "sub_crafts_wiring_kit.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "electronics",
    output = {"sub_crafts:wiring_kit"},
    recipe = {"sub_core:silver 2"}
})

--Filtered water, early-game source of water
minetest.register_craftitem("sub_crafts:filtered_water", {
    description = "Filtered Water",
    inventory_image = "sub_crafts_filtered_water.png",
    on_place = sub_core.item_eat(0, 20),
    on_secondary_use = sub_core.item_eat(0, 20)
})

sub_crafts.register_craft({
    category = "sustenance",
    subcategory = "water",
    output = {"sub_crafts:filtered_water"},
    recipe = {"sub_mobs:item_bladderfish"}
})

--Cooked fish of various sorts
local function cooked_fish(input, output, desc, image, food, water)
    minetest.register_craftitem(output, {
        description = desc,
        inventory_image = image,
        on_place = sub_core.item_eat(food, water),
        on_secondary_use = sub_core.item_eat(food, water)
    })
    
    sub_crafts.register_craft({
        category = "sustenance",
        subcategory = "cooked",
        output = {output},
        recipe = {input}
    })
end

cooked_fish("sub_mobs:item_peeper", "sub_crafts:cooked_peeper", "Cooked Peeper", "sub_crafts_cooked_peeper.png", 32, 5)
cooked_fish("sub_mobs:item_bladderfish", "sub_crafts:cooked_bladderfish", "Cooked Bladderfish", "sub_crafts_cooked_bladderfish.png", 16, 4)
cooked_fish("sub_mobs:item_boomerang", "sub_crafts:cooked_boomerang", "Cooked Boomerang", "sub_crafts_cooked_boomerang.png", 21, 3)
cooked_fish("sub_mobs:item_garryfish", "sub_crafts:cooked_garryfish", "Cooked Garryfish", "sub_crafts_cooked_garryfish.png", 18, 5)
cooked_fish("sub_mobs:item_spadefish", "sub_crafts:cooked_spadefish", "Cooked Spadefish", "sub_crafts_cooked_spadefish.png", 23, 3)
cooked_fish("sub_mobs:item_hoopfish", "sub_crafts:cooked_hoopfish", "Cooked Hoopfish", "sub_crafts_cooked_hoopfish.png", 23, 3)
cooked_fish("sub_mobs:item_hoverfish", "sub_crafts:cooked_hoverfish", "Cooked Hoverfish", "sub_crafts_cooked_hoverfish.png", 23, 3)
cooked_fish("sub_mobs:item_eyeye", "sub_crafts:cooked_eyeye", "Cooked Eyeye", "sub_crafts_cooked_eyeye.png", 18, 10)
cooked_fish("sub_mobs:item_reginald", "sub_crafts:cooked_reginald", "Cooked Reginald", "sub_crafts_cooked_reginald.png", 44, 4)

--First aid kit, pretty much the only method of restoring player's hp
minetest.register_craftitem("sub_crafts:medkit", {
    description = "First Aid Kit",
    inventory_image = "sub_crafts_medkit.png",
    on_place = minetest.item_eat(10),
    on_secondary_use = minetest.item_eat(10)
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "equipment",
    output = {"sub_crafts:medkit"},
    recipe = {"sub_crafts:fiber_mesh"}
})

--Compass, equippable chip which gives a readout of the direction
local compass_huds = {}

minetest.register_craftitem("sub_crafts:compass", {
    description = "Compass",
    inventory_image = "mcl_compass_compass_20.png",
    _equip = "chips",
    _on_equip = function (player)
        compass_huds[player] = player:hud_add({
            hud_elem_type = "compass",
            position = {x=0.5, y=0},
            alignment = {x=0, y=1},
            offset = {x=0, y=72},
            size = {x=256, y=64},
            scale = {x=1, y=1},
            direction = 2,
            text = "hud_compass_straight.png"
        })
    end,
    _on_unequip = function (player)
        if compass_huds[player] then
            player:hud_remove(compass_huds[player])
            compass_huds[player] = nil
        end
    end
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "equipment",
    output = {"sub_crafts:compass"},
    recipe = {"sub_crafts:copper_wire", "sub_crafts:wiring_kit"}
})

--Survival knife, essential for gathering many crafting materials
minetest.register_craftitem("sub_crafts:knife", {
    description = "Survival Knife",
    inventory_image = "sub_crafts_knife.png",
    stack_max = 1,
    tool_capabilities = {
        full_punch_interval = 0.5,
        damage_groups = {normal=4} --note that hp in this game is 1/5 of that in Subnautica, as the player has 20 hp
    }
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "tools",
    output = {"sub_crafts:knife"},
    recipe = {"sub_core:titanium", "sub_crafts:rubber"}
})