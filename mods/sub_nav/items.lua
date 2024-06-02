--Beacon, multipurpose waypoint marker, can be placed on any surface
minetest.register_entity("sub_nav:beacon", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "beacon.obj",
        textures = {"beacon.png"},
        selectionbox = {-0.125, -0.25, -0.125, 0.125, 0.25, 0.125},
        physical = false
    },
    on_activate = function (self, staticdata, dtime)
        if staticdata and staticdata ~= "" then
            self.waypoint = tonumber(staticdata)
        else
            self.waypoint = sub_nav.set_waypoint(self.object:get_pos(), {
                name = "Beacon",
                image = "waypoint_beacon.png",
                dist = 2
            })
        end
    end,
    on_rightclick = function (self, user)
        if self.waypoint then sub_nav.remove_waypoint(self.waypoint) end
        self.object:remove()
        user:get_inventory():add_item("main", "sub_nav:item_beacon")
    end,
    get_staticdata = function (self)
        return tostring(self.waypoint)
    end
})

minetest.register_craftitem("sub_nav:item_beacon", {
    description = "Beacon",
    inventory_image = "sub_nav_item_beacon.png",
    on_place = function (itemstack, user, pointed)
        minetest.add_entity(pointed.above, "sub_nav:beacon")
        itemstack:take_item()
        return itemstack
    end
})

sub_crafts.register_craft({
    category = "deployables",
    output = {"sub_nav:item_beacon"},
    recipe = {"sub_core:titanium", "sub_core:copper"}
})