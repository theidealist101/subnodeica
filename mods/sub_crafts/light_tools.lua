--These have a separate file because there's quite a few of them with similar light-emitting mechanics
--Other, more complex tools are in the mod they pertain to

--Flare, can be held or placed to emit light
local flare_defs = {
    description = "Placed Flare",
    drawtype = "torchlike",
    tiles = {"sub_crafts_flare.png"},
    selection_box = {type="fixed", fixed={-0.25, -0.5, -0.25, 0.25, -0.375, 0.25}},
    light_source = 12,
    groups = {flare=1},
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
        minetest.place_node(pointed.above, {name=nodename == "air" and "sub_crafts:air_flare" or sub_core.get_waterlogged("sub_crafts:flare", nodename)})
        minetest.get_meta(pointed.above):set_int("wear", itemstack:get_wear())
        itemstack:take_item()
        return itemstack
    end,
    _hovertext = "Place Flare (RMB)",
    _equip = "wield",
    _equip_tick = function (player, itemstack, dtime)
        local wear = itemstack:get_wear()
        wear = math.min(math.max(math.round(wear+dtime*327.5), 0), 65536) --327.5 is approximately 65535/200
        if wear >= 65536 then
            --itemstack:get_definition()._on_unequip(player, itemstack)
        end
        itemstack:set_wear(wear)
    end
})

sub_crafts.register_craft({
    category = "personal",
    subcategory = "tools",
    output = {"sub_crafts:item_flare 5"},
    recipe = {"sub_mobs:cave_sulfur"}
})