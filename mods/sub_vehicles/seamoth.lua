--Settings related to seamoth
local ACCEL = 0.5
local MAX_SPEED = 16
local GRAVITY = -3
local FRICTION = 0.2

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
        local rot = self.object:get_rotation()
        user:set_look_vertical(-rot.x)
        user:set_look_horizontal(rot.y)
        user:set_eye_offset(vector.new(0, -12, 0))
    end,
    on_step = function (self, dtime, moveresult)
        local accel = vector.zero()

        --check there is someone driving
        local driver = self.object:get_children()[1]
        if driver then
            local controls = driver:get_player_control()
            if controls.aux1 then
                driver:set_detach()
                driver:set_eye_offset(vector.zero())
                --based on how it's done in Minetest Game's boats mod
                local dismount_pos = driver:get_pos()
                dismount_pos.y = dismount_pos.y+1
                minetest.after(0.1, function() driver:set_pos(dismount_pos) end)
            else
                local rot = vector.new(-driver:get_look_vertical(), driver:get_look_horizontal(), 0)
                self.object:set_rotation(rot)

                --apply force based on controls
                local forward = ACCEL*mobkit.rot_to_dir(rot)
                local sideways = vector.new(forward.z, 0, -forward.x)
                if controls.up then accel = accel+forward end
                if controls.down then accel = accel-forward*0.5 end
                if controls.right then accel = accel+sideways end
                if controls.left then accel = accel-sideways end
                if controls.jump then accel.y = accel.y+ACCEL end
                if controls.sneak then accel.y = accel.y-ACCEL end
            end
        end

        --do some physics
        if accel == vector.zero() then
            accel = -self.object:get_velocity()
            if vector.length(accel) > FRICTION then accel = FRICTION*vector.normalize(accel) end
            if minetest.get_node(mobkit.get_node_pos(self.object:get_pos())).name == "air" then
                accel.y = accel.y+GRAVITY
            end
        end

        --update motion
        local vel = self.object:get_velocity()+accel
        if vector.length(vel) > MAX_SPEED then vel = MAX_SPEED*vector.normalize(vel) end
        self.object:set_velocity(vel)
        sub_nav.move_waypoint(self.waypoint, self.object:get_pos())
    end,
    get_staticdata = function (self)
        return tostring(self.waypoint)
    end
})

sub_crafts.register_craft({
    type = "constructor",
    output = {"sub_vehicles:seamoth"},
    output_icon = "seamoth_craft",
    output_tooltip = "Seamoth",
    recipe = {"sub_crafts:titanium_ingot", "sub_vehicles:power_cell", "sub_crafts:glass 2", "sub_crafts:lubricant", "sub_core:lead"}
})