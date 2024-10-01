--The few items which can pick up objects and move them around, such as grav traps and propulsion cannons

--Grav trap, a small deployable which sucks in items and small fish
local grav_image = "sub_crafts_grav_trap.png"

minetest.register_entity("sub_crafts:grav_trap", {
    initial_properties = {
        visual = "cube",
        visual_size = {x=0.5625, y=0.5625},
        textures = {grav_image, grav_image, grav_image, grav_image, grav_image, grav_image},
        collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
        physical = true,
        automatic_rotate = 0.5,
    },
    on_rightclick = function (self, user)
        self.object:remove()
        user:get_inventory():add_item("main", "sub_crafts:item_grav_trap")
    end,
    on_step = function (self, dtime)
        local pos = self.object:get_pos()
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 16)) do
            if sub_mobs.is_larger({size=1}, obj) == false and not obj:get_attach() then
                obj:set_attach(minetest.add_entity(obj:get_pos(), "sub_crafts:grav_conduit"))
            end
        end
        minetest.add_particlespawner({
            time = dtime,
            amount = 200*dtime,
            texture = "flare_particle.png^[colorize:#cef0ff:alpha^[opacity:128",
            glow = 15,
            exptime = 1,
            pos = pos,
            radius = {min=0, max=1.5, bias=0.5},
            attract = {kind="point", origin_attached=self.object, strength=1}
        })
    end,
    _hovertext = "Pick up Grav Trap (RMB)"
})

minetest.register_entity("sub_crafts:grav_conduit", {
    initial_properties = {
        visual = "sprite",
        textures = {"blank.png"},
        collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
        physical = true,
        pointable = false,
        static_save = false,
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
                minetest.add_particlespawner({
                    time = dtime,
                    amount = 100*dtime,
                    texture = "[fill:1x1:,:#cef0ff^[opacity:192",
                    size = 0.5,
                    glow = 15,
                    exptime = 1,
                    pos = 0,
                    attached = self.object,
                    attract = {kind="point", origin_attached=obj, strength=1}
                })
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
    end,
    _hovertext = "Place Grav Trap (RMB)"
})

sub_crafts.register_craft({
    category = "deployables",
    output = {"sub_crafts:item_grav_trap"},
    recipe = {"sub_crafts:battery", "sub_core:copper", "sub_core:titanium"}
})