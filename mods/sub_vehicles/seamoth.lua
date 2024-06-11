--Seamoth, one-manned submersible, small and unarmored but easily manoevrable and extendable
minetest.register_entity("sub_vehicles:seamoth", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=20, y=20},
        mesh = "seamoth.obj",
        textures = {"seamoth.png"},
        collisionbox = {-1, -1, -1, 1, 1, 1},
        physical = true
    },
    on_activate = function (self, staticdata)
        if staticdata and staticdata ~= "" then
            self.waypoint = tonumber(staticdata)
        else
            self.waypoint = sub_nav.set_waypoint(self.object:get_pos(), {
                name = "Seamoth",
                image = "waypoint_seamoth.png",
                dist = 6
            })
        end
    end,
    on_rightclick = function (self, user)
        user:set_attach(self.object)
    end,
    on_step = function (self, dtime, moveresult)
        sub_nav.move_waypoint(self.waypoint, self.object:get_pos())
        local driver = self.object:get_children()[1]
        if not driver then return end
        local controls = driver:get_player_control()
        if controls.aux1 then
            driver:set_detach()
            return
        end
    end,
    get_staticdata = function (self)
        return tostring(self.waypoint)
    end
})