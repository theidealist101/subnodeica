--Titanium crafted from metal salvage
sub_crafts.register_craft({
    category = "resources",
    subcategory = "basic",
    output = {"sub_core:titanium 4"},
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
    output = {"sub_crafts:rubber 2"},
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

--Battery, essential for tools, has a limited amount of power
minetest.register_tool("sub_crafts:battery", {
    description = "Battery",
    inventory_image = "sub_crafts_battery.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "electronics",
    output = {"sub_crafts:battery"},
    recipe = {"sub_core:item_acidshroom 2", "sub_core:copper"}
})

--Battery switching function, to be used in on_use by battery-powered tools
function sub_crafts.switch_battery(itemstack, user, pointed)
    local inv = user:get_inventory()
    local out = {"bgcolor[black;neither]"}
    local x_offset = 0
    for i = 1, inv:get_size("main") do
        local item = inv:get_stack("main", i)
        if item:get_name() == "sub_crafts:battery" then
            table.insert(out, "item_image_button["..x_offset..",0;1,1;sub_crafts:battery;slot"..i..";]")
            --TODO: show wear here as well
            x_offset = x_offset+1.25
        end
    end
    if #out <= 1 then return end
    minetest.show_formspec(user:get_player_name(), "sub_crafts:battery_formspec", "formspec_version[4]size["..(x_offset-0.25)..",1,true]"..table.concat(out))
end

--Switch battery upon receiving choice
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "sub_crafts:battery_formspec" then return end
    for name, value in pairs(fields) do
        if value then
            if name == "quit" then return end
            local i = tonumber(string.sub(name, 5))
            local inv = player:get_inventory()
            local wield_item, battery = player:get_wielded_item(), inv:get_stack("main", i)
            local battery_wear = battery:get_wear()
            battery:set_wear(wield_item:get_wear())
            wield_item:set_wear(battery_wear)
            inv:set_stack(player:get_wield_list(), player:get_wield_index(), wield_item)
            inv:set_stack("main", i, battery)
            minetest.close_formspec(player:get_player_name(), "sub_crafts:battery_formspec")
            return
        end
    end
end)

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
    on_use = sub_core.item_eat(0, 20)
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
        on_use = sub_core.item_eat(food, water)
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

--Standard O2 tank, equippable item which increases player's oxygen capacity
minetest.register_tool("sub_crafts:o2_tank", {
    description = "Standard O2 Tank",
    inventory_image = "sub_crafts_o2_tank.png",
    _equip = "tank",
    _on_equip = function (player, itemstack)
        itemstack:get_meta():set_int("monoid", sub_core.o2_monoid:add_change(player, 30))
        player:set_breath(math.min(player:get_breath()+30*(1-itemstack:get_wear()/65535), sub_core.max_breath+30))
    end,
    _on_unequip = function (player, itemstack)
        sub_core.o2_monoid:del_change(player, itemstack:get_meta():get_int("monoid"))
    end
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "equipment",
    output = {"sub_crafts:o2_tank"},
    recipe = {"sub_core:titanium 3"}
})

minetest.register_tool("sub_crafts:double_o2_tank", {
    description = "High Capacity O2 Tank",
    inventory_image = "sub_crafts_double_o2_tank.png",
    _equip = "tank",
    _on_equip = function (player, itemstack)
        itemstack:get_meta():set_int("monoid", sub_core.o2_monoid:add_change(player, 90))
        player:set_breath(math.min(player:get_breath()+90*(1-itemstack:get_wear()/65535), sub_core.max_breath+90))
    end,
    _on_unequip = function (player, itemstack)
        sub_core.o2_monoid:del_change(player, itemstack:get_meta():get_int("monoid"))
    end
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "equipment",
    output = {"sub_crafts:double_o2_tank"},
    recipe = {"sub_crafts:o2_tank", "sub_crafts:glass 2", "sub_core:titanium 4", "sub_core:silver"}
})

sub_crafts.register_on_craft(function(itemstack, player)
    if itemstack:get_name() == "sub_crafts:o2_tank" or itemstack:get_name() == "sub_crafts:double_o2_tank" then
        itemstack:set_wear(65535)
        return itemstack
    end
end)

--Fins, equippable item which increases player's speed in water
minetest.register_craftitem("sub_crafts:fins", {
    description = "Fins",
    inventory_image = "sub_crafts_fins.png",
    _equip = "feet",
    _on_equip = function (player, itemstack)
        itemstack:get_meta():set_int("monoid", sub_core.swim_monoid:add_change(player, 1.15))
    end,
    _on_unequip = function (player, itemstack)
        sub_core.swim_monoid:del_change(player, itemstack:get_meta():get_int("monoid"))
    end
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "equipment",
    output = {"sub_crafts:fins"},
    recipe = {"sub_crafts:rubber 2"}
})

--First aid kit, pretty much the only method of restoring player's hp
minetest.register_craftitem("sub_crafts:medkit", {
    description = "First Aid Kit",
    inventory_image = "sub_crafts_medkit.png",
    on_use = function (itemstack, user, pointed)
        if user:get_hp() < 20 then return minetest.do_item_eat(10, nil, itemstack, user, pointed) end
    end
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

local bladder_accel = vector.new(0, 60, 0)

--Air bladder, can be used to restore oxygen or go up quickly
local function air_bladder_on_place(itemstack)
    local meta = itemstack:get_meta()
    meta:set_int("inflated", meta:get_int("inflated") > 0 and 0 or 1)
    return itemstack
end

minetest.register_tool("sub_crafts:air_bladder", {
    description = "Air Bladder",
    inventory_image = "sub_crafts_air_bladder.png",
    on_use = function (itemstack, user)
        user:set_breath(user:get_breath()+(65535-itemstack:get_wear())/4369) --4369 == 65535/15
        itemstack:set_wear(65535)
        return itemstack
    end,
    on_place = air_bladder_on_place,
    on_secondary_use = air_bladder_on_place,
    _hovertext = function (itemstack)
        if itemstack:get_wear() >= 65535 then return end
        return "Consume oxygen (LMB)\n"..(itemstack:get_meta():get_int("inflated") > 0 and "Deflate" or "Inflate").." Air Bladder (RMB)"
    end,
    _equip = "wield",
    _equip_tick = function (player, itemstack, dtime)
        if player:get_pos().y+1.625 > 0 and itemstack:get_wear() > 0 then
            itemstack:set_wear(math.max(itemstack:get_wear()-dtime*65535, 0))
            itemstack:get_meta():set_int("inflated", 0)
        elseif itemstack:get_wear() >= 65535 then
            itemstack:get_meta():set_int("inflated", 0)
        elseif itemstack:get_meta():get_int("inflated") > 0 then
            player:add_velocity(dtime*bladder_accel)
            itemstack:set_wear(math.min(itemstack:get_wear()+dtime*10000, 65535))
        end
        return itemstack
    end
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "tools",
    output = {"sub_crafts:air_bladder"},
    recipe = {"sub_mobs:item_bladderfish", "sub_crafts:rubber"}
})

--Grav trap, a small deployable which sucks in items and small fish
local grav_image = "sub_crafts_grav_trap.png"

minetest.register_entity("sub_crafts:grav_trap", {
    initial_properties = {
        visual = "cube",
        visual_size = {x=0.5625, y=0.5625},
        textures = {grav_image, grav_image, grav_image, grav_image, grav_image, grav_image},
        selectionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
        physical = true,
    },
    on_rightclick = function (self, user)
        self.object:remove()
        user:get_inventory():add_item("main", "sub_crafts:item_grav_trap")
    end,
    on_step = function (self)
        for _, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 16)) do
            if sub_mobs.is_larger({size=1}, obj) == false and not obj:get_attach() then
                obj:set_attach(minetest.add_entity(obj:get_pos(), "sub_crafts:grav_conduit"))
            end
        end
    end,
    _hovertext = "Pick up Grav Trap (RMB)"
})

minetest.register_entity("sub_crafts:grav_conduit", {
    initial_properties = {
        visual = "sprite",
        textures = {"blank.png"},
        physical = true,
        pointable = false,
        static_save = false
    },
    on_step = function (self, dtime)
        if #self.object:get_children() == 0 then self.object:remove() return end
        local grav = false
        for _, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 16)) do
            if not obj:is_player() and obj:get_luaentity().name == "sub_crafts:grav_trap" then
                local pos = self.object:get_pos()
                local dir = obj:get_pos()-pos
                self.object:add_velocity(0.1*vector.normalize(dir))
                grav = true
            end
        end
        if not grav then self.object:remove() end
    end
})

minetest.register_craftitem("sub_crafts:item_grav_trap", {
    description = "Grav Trap",
    inventory_image = "sub_crafts_item_grav_trap.png",
    on_place = function (itemstack, user, pointed)
        minetest.add_entity(pointed.above, "sub_crafts:grav_trap")
        itemstack:take_item()
        return itemstack
    end
})

sub_crafts.register_craft({
    category = "deployables",
    output = {"sub_crafts:item_grav_trap"},
    recipe = {"sub_crafts:battery", "sub_core:copper", "sub_core:titanium"}
})