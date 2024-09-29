--Power cell, essential for vehicles
minetest.register_craftitem("sub_vehicles:power_cell", {
    description = "Power Cell",
    inventory_image = "sub_vehicles_power_cell.png"
})

sub_crafts.register_craft({
    category = "resources",
    subcategory = "electronics",
    output = {"sub_vehicles:power_cell"},
    recipe = {"sub_crafts:battery 2", "sub_crafts:rubber"}
})

--Mobile vehicle bay, deployable entity, floats to the surface and can be used to craft vehicles
minetest.register_entity("sub_vehicles:constructor", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=15, y=15},
        mesh = "constructor.obj",
        textures = {"constructor.png"},
        collisionbox = {-0.75, 0, -0.75, 0.75, 0.375, 0.75},
        physical = true
    },
    on_activate = function (self)
        if #self.object:get_children() == 0 then
            local console = minetest.add_entity(self.object:get_pos(), "sub_vehicles:constructor_console", "true")
            console:set_attach(self.object)
        end
    end,
    on_step = function (self)
        local node = minetest.get_node(mobkit.get_node_pos(self.object:get_pos()))
        self.object:set_velocity(node.name == "air" and vector.zero() or vector.new(0, 1, 0))
    end,
    on_rightclick = function (self, user)
        for i, obj in ipairs(self.object:get_children()) do obj:remove() end
        self.object:remove()
        user:get_inventory():add_item("main", "sub_vehicles:item_constructor")
    end,
    _hovertext = "Pack up Mobile Vehicle Bay (RMB)"
})

minetest.register_entity("sub_vehicles:constructor_console", {
    initial_properties = {
        visual = "sprite",
        textures = {"blank.png"},
        selectionbox = {-0.25, 1.5, -0.5, 0.25, 2, -0.25},
        physical = false
    },
    on_activate = function (self, staticdata)
        if not self.object:get_attach() and (not staticdata or staticdata == "") then self.object:remove() end
    end,
    on_rightclick = function (self, user)
        minetest.show_formspec(user:get_player_name(), "sub_crafts:constructor_formspec", sub_crafts.get_formspec(user, "constructor"))
    end,
    _hovertext = "Use Mobile Vehicle Bay (RMB)"
})

minetest.register_craftitem("sub_vehicles:item_constructor", {
    description = "Mobile Vehicle Bay",
    stack_max = 1,
    inventory_image = "sub_vehicles_constructor.png",
    on_place = function (itemstack, user, pointed)
        minetest.add_entity(pointed.above, "sub_vehicles:constructor")
        itemstack:take_item()
        return itemstack
    end,
    _hovertext = "Deploy Mobile Vehicle Bay (RMB)"
})

sub_crafts.register_craft({
    type = "fabricator",
    category = "deployables",
    output = {"sub_vehicles:item_constructor"},
    recipe = {"sub_crafts:titanium_ingot", "sub_crafts:lubricant", "sub_vehicles:power_cell"}
})

local creative = minetest.settings:get_bool("creative_mode")

--largely copied from sub_crafts
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "sub_crafts:constructor_formspec" then return end
    local playername = player:get_player_name()
    local inv = player:get_inventory()
    for name, value in pairs(fields) do
        if value then
            if name == "quit" then return end
            local names = string.split(name, "|")
            --test if it can be a recipe
            local names2 = table.copy(names)
            table.insert(names2, 1, table.remove(names2, #names2))
            local recipe = sub_crafts.get_recipe("constructor", unpack(names2))
            if recipe and sub_crafts.can_do_recipe(inv, recipe.recipe) then
                if not creative then
                    for i, item in ipairs(recipe.recipe) do
                        inv:remove_item("main", ItemStack(item))
                    end
                end
                minetest.add_entity(
                    player:get_pos()+8*mobkit.rot_to_dir(vector.new(0, player:get_look_horizontal(), 0))+vector.new(0, 4, 0),
                    recipe.output[1]
                )
                table.remove(names, #names)
            end
            --show the corresponding menu
            local formspec = sub_crafts.get_formspec(player, "constructor", unpack(names))
            minetest.show_formspec(playername, formname, formspec)
            return
        end
    end
end)