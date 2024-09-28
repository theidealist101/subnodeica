--Settings related to seamoth
local ACCEL = 0.5
local MAX_SPEED = 16
local GRAVITY = -1
local FRICTION = 0.3

local enable_damage = minetest.settings:get_bool("enable_damage")

local seamoth_collide = {
    full_punch_interval = 1,
    damage_groups = {normal=5}
}

--Seamoth, one-manned submersible, small and unarmored but easily manoevrable and extendable
local function seamoth_on_step(self, dtime, moveresult)
    local accel = vector.zero()
    local in_air = minetest.get_node(mobkit.get_node_pos(self.object:get_pos())).name == "air"
    local driver = self.object:get_children()[1]

    --check for collisions
    local speed = vector.length(self.object:get_velocity())
    if #moveresult.collisions > 0 and speed > 10 and self.iframes <= 0 then
        for i, col in ipairs(moveresult.collisions) do
            if col.type == "object" then
                col.object:punch(self.object, speed/MAX_SPEED, seamoth_collide)
            end
        end
        self.object:punch(self.object, speed/MAX_SPEED, seamoth_collide)
        self.iframes = 10 --prevents lots of small node collisions dealing too much damage
        if not mobkit.exists(self) then
            if driver then sub_vehicles.remove_huds(driver) end
            return
        end
    elseif self.iframes > 0 then
        self.iframes = self.iframes-1
    end

    --check there is someone driving
    if driver then
        local controls = driver:get_player_control()
        if controls.aux1 then
            driver:set_detach()
            driver:set_eye_offset(vector.zero())
            if enable_damage then sub_vehicles.remove_huds(driver) end
            --based on how it's done in Minetest Game's boats mod
            local dismount_pos = driver:get_pos()
            dismount_pos.y = dismount_pos.y+1
            minetest.after(0.1, function() driver:set_pos(dismount_pos) end)
        else
            if enable_damage then sub_vehicles.update_huds(driver) end
            local rot = vector.new(-driver:get_look_vertical(), driver:get_look_horizontal(), 0)
            self.object:set_rotation(rot)

            --apply force based on controls
            if not in_air then
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
    end

    --do some physics
    if accel == vector.zero() then
        accel = -self.object:get_velocity()
        if vector.length(accel) > FRICTION then accel = FRICTION*vector.normalize(accel) end
        if in_air then
            accel.y = accel.y+GRAVITY
        end
    end

    --update motion
    local vel = self.object:get_velocity()+accel
    if vector.length(vel) > MAX_SPEED then vel = MAX_SPEED*vector.normalize(vel) end
    self.object:set_velocity(vel)
    sub_nav.move_waypoint(self.waypoint, self.object:get_pos())
end

minetest.register_entity("sub_vehicles:seamoth", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=20, y=20},
        mesh = "seamoth.obj",
        textures = {"seamoth.png"},
        collisionbox = {-1, -1, -1, 1, 1, 1},
        physical = true,
        hp_max = 60
    },
    breathable = true,
    on_activate = function (self, staticdata)
        if enable_damage then
            self.object:set_armor_groups({
                normal = 100,
                gas = 100,
                fire = 100
            })
        end
        self.iframes = 0
        if staticdata and staticdata ~= "" then
            local waypoint, hp = unpack(minetest.deserialize(staticdata))
            self.waypoint = waypoint
            self.object:set_hp(hp)
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
        if enable_damage then
            sub_vehicles.add_huds(user, self.object)
        end
    end,
    on_step = seamoth_on_step,
    on_death = function (self)
        sub_nav.remove_waypoint(self.waypoint)
    end,
    get_staticdata = function (self)
        return minetest.serialize({self.waypoint, self.object:get_hp()})
    end
})

sub_crafts.register_craft({
    type = "constructor",
    output = {"sub_vehicles:seamoth"},
    output_icon = "seamoth_craft.png",
    output_tooltip = "Seamoth",
    recipe = {"sub_crafts:titanium_ingot", "sub_vehicles:power_cell", "sub_crafts:glass 2", "sub_crafts:lubricant", "sub_core:lead"}
})