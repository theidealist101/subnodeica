--These have a separate file because there's quite a few of them with similar light-emitting mechanics
--Other, more complex tools are in the mod they pertain to

--Flare, can be held or placed to emit light
local flare_defs = {
    description = "Placed Flare",
    drawtype = "torchlike",
    tiles = {"sub_crafts_flare.png"},
    selection_box = {type="fixed", fixed={-0.25, -0.5, -0.25, 0.25, -0.375, 0.25}},
    walkable = false,
    light_source = 12,
    on_rightclick = function (pos, node, user, itemstack)
        local out = ItemStack("sub_crafts:item_flare")
        out:set_wear(minetest.get_meta(pos):get_int("wear"))
        minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent or "air"})
        return sub_core.give_item(out)(pos, node, user, itemstack)
    end,
    on_construct = function (pos)
        minetest.get_node_timer(pos):start(0.1)
    end,
    _hovertext = "Pick up Flare (RMB)"
}

local diag = 0.2*vector.new(1, 1, 1)
local up = vector.new(0, 1, 0)
local flare_offset = vector.new(0.175, -0.4375, 0.175)

flare_defs.on_timer = function (pos, dtime)
    local meta = minetest.get_meta(pos)
    meta:set_int("wear", meta:get_int("wear")+dtime*327.5) --see below
    if meta:get_int("wear") >= 65536 then
        minetest.set_node(pos, {name=minetest.registered_nodes[minetest.get_node(pos).name]._water_equivalent or "air"})
        return
    end
    minetest.add_particlespawner({
        time = 0.1,
        amount = 5,
        texture = {name="flare_particle.png", alpha_tween={1, 0.5}},
        pos = pos+flare_offset,
        vel = {min=-diag, max=diag},
        drag = 2,
        acc = {min=2*up, max=3*up},
        exptime = {min=1, max=3},
        glow = 15
    })
    return true
end

minetest.register_node("sub_crafts:air_flare", flare_defs)
sub_core.register_waterloggable("sub_crafts:flare", flare_defs)

minetest.register_tool("sub_crafts:item_flare", {
    description = "Flare",
    inventory_image = "sub_crafts_item_flare.png",
    on_place = function (itemstack, user, pointed)
        local nodename = minetest.get_node(pointed.above).name
        if pointed.above.y-pointed.under.y ~= 1 or minetest.registered_nodes[nodename].drawtype ~= "airlike" then return end
        minetest.set_node(pointed.above, {name=nodename == "air" and "sub_crafts:air_flare" or sub_core.get_waterlogged("sub_crafts:flare", nodename)})
        minetest.get_meta(pointed.above):set_int("wear", itemstack:get_wear())
        itemstack:take_item()
        return itemstack
    end,
    _hovertext = "Place Flare (RMB)",
    _equip = "wield",
    --[[_equip_tick = function (player, itemstack, dtime)
        local wear = itemstack:get_wear()
        wear = math.min(math.max(math.round(wear+dtime*327.5), 0), 65536) --327.5 is approximately 65535/200
        if wear >= 65536 then
            --itemstack:get_definition()._on_unequip(player, itemstack)
        end
        itemstack:set_wear(wear)
    end]]
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "tools",
    output = {"sub_crafts:item_flare 5"},
    recipe = {"sub_mobs:cave_sulfur"}
})

--Light stick, does sort of the same thing but brighter and doesn't wear out
local light_stick_defs = {
    description = "Placed Light Stick",
    drawtype = "mesh",
    mesh = "double_plantlike_down.obj",
    tiles = {"sub_crafts_light_stick.png"},
    use_texture_alpha = "clip",
    selection_box = {type="fixed", fixed={-0.125, -1.5, -0.125, 0.125, 0.25, 0.125}},
    walkable = false,
    light_source = 14,
    on_rightclick = function (pos, node, user, itemstack)
        minetest.set_node(pos, {name=minetest.registered_nodes[node.name]._water_equivalent or "air"})
        return sub_core.give_item("sub_crafts:item_light_stick")(pos, node, user, itemstack)
    end,
    _hovertext = "Pick up Light Stick (RMB)"
}

minetest.register_node("sub_crafts:air_light_stick", light_stick_defs)
sub_core.register_waterloggable("sub_crafts:light_stick", light_stick_defs)

minetest.register_craftitem("sub_crafts:item_light_stick", {
    description = "Light Stick",
    inventory_image = "sub_crafts_item_light_stick.png",
    on_place = function (itemstack, user, pointed)
        local nodename = minetest.get_node(pointed.above+up).name
        if pointed.above.y-pointed.under.y ~= 1 or minetest.registered_nodes[nodename].drawtype ~= "airlike" then return end
        minetest.set_node(pointed.above+up, {name=nodename == "air" and "sub_crafts:air_light_stick" or sub_core.get_waterlogged("sub_crafts:light_stick", nodename)})
        itemstack:take_item()
        return itemstack
    end,
    _hovertext = "Place Light Stick (RMB)",
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "tools",
    output = {"sub_crafts:item_light_stick"},
    recipe = {"sub_crafts:battery", "sub_core:titanium", "sub_crafts:glass"}
})

--Pathfinder tool, used to show the way out of places
local path_defs = {
    description = "Path Node",
    drawtype = "plantlike",
    tiles = {"sub_crafts_path_node.png"},
    selection_box = {type="fixed", fixed={-0.125, -0.5, -0.125, 0.125, -0.375, 0.125}},
    use_texture_alpha = "blend",
    walkable = false,
    paramtype = "light",
    sunlight_propagates = true,
    light_source = 7,
    groups = {path_node=1},
    on_construct = function (pos)
        pos.y = pos.y+0.25
        minetest.add_entity(pos, "sub_crafts:path_marker")
    end
}

minetest.register_node("sub_crafts:air_path_node", path_defs)
sub_core.register_waterloggable("sub_crafts:path_node", path_defs)

minetest.register_entity("sub_crafts:path_marker", {
    initial_properties = {
        visual = "sprite",
        visual_size = {x=0.3, y=0.3},
        textures = {"path_start.png"},
        use_texture_alpha = true,
        physical = false,
        pointable = false,
        glow = 15
    },
    on_step = function (self)
        if minetest.get_item_group(minetest.get_node(vector.round(self.object:get_pos())).name, "path_node") <= 0 then self.object:remove() end
    end
})

minetest.register_tool("sub_crafts:pathfinder", {
    description = "Pathfinder",
    inventory_image = "sub_crafts_pathfinder.png",
    on_place = function (itemstack, user, pointed)
        local nodename = minetest.get_node(pointed.above).name
        local node_under = minetest.get_node(pointed.under).name
        if minetest.get_item_group(node_under, "path_node") > 0 then
            minetest.set_node(pointed.under, {name=minetest.registered_nodes[node_under]._water_equivalent or "air"})
            return
        end
        if pointed.above.y-pointed.under.y ~= 1 or minetest.registered_nodes[nodename].drawtype ~= "airlike" then return end
        local wear = itemstack:get_wear()
        if wear >= 65535 then return end
        minetest.set_node(pointed.above, {name=nodename == "air" and "sub_crafts:air_path_node" or sub_core.get_waterlogged("sub_crafts:path_node", nodename)})
        wear = math.min(math.max(math.round(wear+327.5), 0), 65535) --327.5 is approximately 65535/200
        itemstack:set_wear(wear)
        return itemstack
    end,
    on_use = sub_crafts.switch_battery,
    _hovertext = function (itemstack, user, pointed)
        if itemstack:get_wear() >= 65535 then return "Switch battery (LMB)" end
        if pointed.type ~= "node" then return end
        local nodename = minetest.get_node(pointed.under).name
        if minetest.get_item_group(nodename, "path_node") > 0 then
            return "Pick up path node (RMB)"
        else
            return "Place path node (RMB)"
        end
    end
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "tools",
    output = {"sub_crafts:pathfinder"},
    recipe = {"sub_core:creepvine_seeds 2", "sub_crafts:copper_wire", "sub_core:titanium"}
})