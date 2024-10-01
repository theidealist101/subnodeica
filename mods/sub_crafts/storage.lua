--Waterproof locker, a deployable with a small inventory
minetest.register_entity("sub_crafts:water_locker", {
    initial_properties = {
        visual = "upright_sprite", --placeholder
        textures = {"sub_crafts_item_water_locker.png"}
    },
    on_activate = function (self, staticdata)
        sub_inv.add_entity_inv(self, 16, staticdata)
    end,
    on_deactivate = sub_inv.del_entity_inv,
    get_staticdata = sub_inv.save_entity_inv,
    on_rightclick = sub_inv.show_entity_inv,
    on_punch = function (self, user)
        if not user:is_player() or not sub_inv.get_entity_inv(self):is_empty("main") then return end
        self.object:remove()
        user:get_inventory():add_item("main", "sub_crafts:item_water_locker")
    end,
    _hovertext = function (itemstack, user, pointed)
        return (sub_inv.get_entity_inv(pointed.ref):is_empty("main") and "Pick up Waterproof Locker (LMB)\n" or "").."Open locker inventory (RMB)"
    end
})

minetest.register_craftitem("sub_crafts:item_water_locker", {
    description = "Waterproof Locker",
    inventory_image = "sub_crafts_item_water_locker.png",
    _hovertext = "Place Waterproof Locker (RMB)",
    on_place = function (itemstack, user, pointed)
        minetest.add_entity(pointed.above, "sub_crafts:water_locker")
        itemstack:take_item()
        return itemstack
    end
})

sub_crafts.register_craft({
    category = "deployables",
    output = {"sub_crafts:item_water_locker"},
    recipe = {"sub_core:titanium 4"}
})