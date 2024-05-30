--Give player itemstack on rightclick
function sub_core.give_item(name)
    return function (pos, node, user, itemstack)
        if itemstack:is_empty() then
            return ItemStack(name)
        elseif itemstack:get_name() == name and itemstack:get_free_space() > 0 then
            itemstack:set_count(itemstack:get_count()+1)
        else
            user:get_inventory():add_item("main", name)
        end
        return itemstack
    end
end

--Drop item if hit by a knife
function sub_core.drop_if_slash(item, no_break)
    return function (pos, node, user, pointed)
        if user:is_player() then
            local itemstack = user:get_wielded_item()
            if not itemstack:is_empty() and itemstack:get_tool_capabilities().damage_groups.normal then
                if no_break then
                    minetest.add_item(pointed.above, item)
                else
                    minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent})
                    minetest.add_item(pos, item)
                end
            end
        end
    end
end

--General nodes which appear in many biomes
--For more specific nodes see the file for their biome
minetest.register_node("sub_core:stone", {
    description = "Stone",
    tiles = {"default_stone.png"}
})

minetest.register_alias("mapgen_stone", "sub_core:stone")

minetest.register_node("sub_core:sand", {
    description = "Sand",
    tiles = {"default_sand.png"}
})

minetest.register_node("sub_core:sandstone", {
    description = "Sandstone",
    tiles = {"default_sandstone.png"}
})

minetest.register_node("sub_core:sand_with_lichen", {
    description = "Sand with Lichen",
    tiles = {"default_sand.png^sub_core_lichen.png"}
})

--Common decorations that appear in many biomes
--Each biome creates its own variant with its water color
sub_core.veined_nettle_defs = {
    description = "Veined Nettle",
    drawtype = "plantlike",
    tiles = {"sub_core_veined_nettle.png"},
    inventory_image = "sub_core_veined_nettle.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.375, 0.25}
    },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {attached_node=1}
}

sub_core.writhing_weed_defs = {
    description = "Writhing Weed",
    drawtype = "plantlike",
    tiles = {"sub_core_writhing_weed.png"},
    inventory_image = "sub_core_writhing_weed.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0.25, 0.375}
    },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {attached_node=1}
}

sub_core.blue_palm_defs = {
    description = "Blue Palm",
    drawtype = "mesh",
    mesh = "palm.obj",
    tiles = {"blue_palm.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0.25, 0.375}
    },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    buildable_to = true,
    groups = {attached_node=1}
}

--Acid mushrooms, important for batteries
local function acidshroom_on_rightclick(pos, node, user, itemstack)
    minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent})
    return sub_core.give_item("sub_core:item_acidshroom")(pos, node, user, itemstack)
end

sub_core.acidshroom1_defs = {
    description = "Acidshrooms",
    drawtype = "mesh",
    mesh = "acidshroom1.obj",
    tiles = {"acidshroom.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0, 0.375}
    },
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    walkable = false,
    groups = {attached_node=1},
    on_rightclick = acidshroom_on_rightclick
}

sub_core.acidshroom2_defs = {
    description = "Acidshrooms",
    drawtype = "mesh",
    mesh = "acidshroom2.obj",
    tiles = {"acidshrooms.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0, 0.375}
    },
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    walkable = false,
    groups = {attached_node=1},
    on_rightclick = acidshroom_on_rightclick
}

sub_core.acidshroom3_defs = {
    description = "Acidshrooms",
    drawtype = "mesh",
    mesh = "acidshroom3.obj",
    tiles = {"acidshrooms.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0, 0.375}
    },
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    walkable = false,
    groups = {attached_node=1},
    on_rightclick = acidshroom_on_rightclick
}

sub_core.acidshroom4_defs = {
    description = "Acidshrooms",
    drawtype = "mesh",
    mesh = "acidshroom4.obj",
    tiles = {"acidshroom_small.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, -0.25, 0.375}
    },
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    walkable = false,
    groups = {attached_node=1},
    on_rightclick = acidshroom_on_rightclick
}

minetest.register_craftitem("sub_core:item_acidshroom", {
    description = "Acidshroom",
    inventory_image = "sub_core_acidshroom.png"
})

--Table coral, important for certain electronics
sub_core.table_coral_defs = {
    description = "Table Coral",
    drawtype = "mesh",
    mesh = "table_coral.obj",
    tiles = {"table_coral_red.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.4375, -0.5, -0.3125, 0.4375, 0, 0.3125}
    },
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    on_punch = sub_core.drop_if_slash("sub_core:table_coral_sample")
}

minetest.register_craftitem("sub_core:table_coral_sample", {
    description = "Table Coral Sample",
    inventory_image = "sub_core_table_coral_sample.png"
})

minetest.register_node("sub_core:sandstone_with_lichen", {
    description = "Sandstone with Lichen",
    tiles = {"default_sandstone.png^sub_core_lichen.png"}
})

--Coral tubes and plates, important for bleach
minetest.register_node("sub_core:coral_tube", {
    description = "Coral Tube Block",
    tiles = {"sub_core_coral_tube.png"},
    on_punch = sub_core.drop_if_slash("sub_core:coral_tube_sample", true)
})

minetest.register_craftitem("sub_core:coral_tube_sample", {
    description = "Coral Tube Sample",
    inventory_image = "sub_core_coral_tube_sample.png"
})

--Harvesting nodes and minerals which come from them
minetest.register_craftitem("sub_core:titanium", {
    description = "Titanium",
    inventory_image = "default_tin_lump.png"
})

minetest.register_craftitem("sub_core:copper", {
    description = "Copper",
    inventory_image = "default_copper_lump.png"
})

sub_core.limestone_defs = {
    description = "Limestone Outcrop",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.1875, 0.25, -0.125, 0.1875}
    },
    tiles = {"sub_core_limestone.png"},
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    on_punch = function (pos, node)
        minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent})
        if math.random() < 0.5 then
            minetest.add_item(pos, "sub_core:titanium")
        else
            minetest.add_item(pos, "sub_core:copper")
        end
    end
}

minetest.register_craftitem("sub_core:lead", {
    description = "Lead",
    inventory_image = "sub_core_lead.png"
})

minetest.register_craftitem("sub_core:silver", {
    description = "Silver",
    inventory_image = "default_clay_lump.png"
})

minetest.register_craftitem("sub_core:gold", {
    description = "Gold",
    inventory_image = "default_gold_lump.png"
})

sub_core.sandstone_defs = {
    description = "Sandstone Outcrop",
    drawtype = "nodebox",
    node_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.1875, 0.25, -0.125, 0.1875}
    },
    tiles = {"default_desert_stone.png"},
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    on_punch = function (pos, node)
        minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent})
        if math.random() < 0.25 then
            minetest.add_item(pos, "sub_core:gold")
        elseif math.random() < 0.5 then
            minetest.add_item(pos, "sub_core:lead")
        else
            minetest.add_item(pos, "sub_core:silver")
        end
    end
}

minetest.register_craftitem("sub_core:quartz", {
    description = "Quartz",
    inventory_image = "sub_core_quartz.png"
})

sub_core.quartz_defs = {
    description = "Quartz Outcrop",
    drawtype = "plantlike",
    tiles = {"sub_core_quartz.png"},
    inventory_image = "sub_core_quartz.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.3125, -0.5, -0.3125, 0.3125, 0.25, 0.3125}
    },
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    on_rightclick = function (pos, node, user, itemstack)
        minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent})
        return sub_core.give_item("sub_core:quartz")(pos, node, user, itemstack)
    end
}

--A couple basic structural nodes (will be moved to sub_wrecks or sub_bases later, dunno which)
minetest.register_node("sub_core:titanium_block", {
    description = "Titanium Block",
    tiles = {"sub_core_titanium_block.png"}
})

minetest.register_node("sub_core:dark_titanium_block", {
    description = "Dark Titanium Block",
    tiles = {"sub_core_dark_titanium_block.png"}
})

minetest.register_node("sub_core:black_titanium_block", {
    description = "Black Titanium Block",
    tiles = {"sub_core_black_titanium_block.png"}
})

--Metal salvage, source of titanium and also used to get stalker teeth
sub_core.salvage1_defs = {
    description = "Metal Salvage",
    drawtype = "mesh",
    mesh = "salvage1.obj",
    tiles = {"salvage1.png"},
    selection_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    },
    paramtype = "light",
    paramtype2 = "4dir",
    sunlight_propagates = true,
    on_rightclick = function (pos, node, user, itemstack)
        minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent})
        return sub_core.give_item("sub_core:salvage")(pos, node, user, itemstack)
    end
}

minetest.register_node("sub_core:salvage", {
    description = "Metal Salvage",
    stack_max = 1,
    drawtype = "mesh",
    mesh = "salvage1.obj",
    tiles = {"salvage1.png"},
    on_place = function (itemstack, user, pointed)
        local node = minetest.get_node(pointed.under)
        local defs = minetest.registered_nodes[node.name]
        if defs and defs.on_rightclick then return defs.on_rightclick(pointed.under, node, user, itemstack, pointed) end
    end --to be replaced later
})