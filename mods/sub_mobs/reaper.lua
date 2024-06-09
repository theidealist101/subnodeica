--Entities which reapers will try to attack (none currently)
local reaper_prey = {
    "sub_mobs:reefback_baby",
    "sub_mobs:sandshark",
    "sub_mobs:stalker",
    "sub_mobs:gasopod"
}

--Thrash around wildly in a death grip
local function hq_reaper_thrash(self, priority, speed, turn_rate)
    local dest
    local finish = minetest.get_gametime()+math.random(5, 10)

    local function out()
        --make sure the object still exists
        if #self.object:get_children() == 0 then return true end

        --release object if run out of time
        if minetest.get_gametime() > finish then
            for i, obj in ipairs(self.object:get_children()) do
                obj:set_detach()
                --obj:set_properties({visual_size={x=1, y=1}})
                obj:punch(self.object, 1, self.attack)
                return true
            end
        end

        --the rest is mostly copied from hq_fish_roam
        --check there is a destination
        local pos = self.object:get_pos()
        if not dest or mobkit.isnear3d(pos, dest, 3) then
            for _ = 1, 16 do
                --pick a random nearby position and check if reachable
                local new_dest = mobkit.get_node_pos(pos+vector.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8)))
                if sub_mobs.in_water(new_dest) and not minetest.raycast(pos, new_dest, false):next() then
                    dest = new_dest
                    break
                end
            end
            if not dest then return end
        end

        --move towards destination
        local dir = vector.normalize(self.object:get_velocity()+vector.normalize(dest-pos)*0.2)
        self.object:set_velocity(dir*speed)
        self.object:set_rotation(mobkit.dir_to_rot(dir))
    end

    mobkit.queue_high(self, out, priority)
end

--Swim towards prey and pick up before shaking around (largely borrowed from stalker's hq_item_pickup)
local function hq_reaper_grab(self, priority, speed, turn_rate, obj)
    local function out()
        --make sure the object still exists and is not picked up
        if not mobkit.exists(obj) or obj:get_attach() then return true end

        --turn towards object
        local pos = self.object:get_pos()
        local dest = obj:get_pos()
        local rot = self.object:get_rotation()
        self.object:set_rotation(sub_mobs.turn_to(rot, mobkit.dir_to_rot(dest-pos), turn_rate))

        --try to pick up object
        if self.attack and mobkit.isnear3d(pos, dest, self.attack.range+0.5) then
            obj:set_attach(self.object, "", {x=0, y=0, z=10}, {x=0, y=0, z=0}, false) --offset not working
            minetest.log(dump({obj:get_attach()}))
            obj:set_properties({visual_size={x=1, y=1}})
            hq_reaper_thrash(self, priority, 10, turn_rate)
            return true
        end

        --move forwards
        self.object:set_velocity(speed*mobkit.rot_to_dir(rot))
    end

    mobkit.queue_high(self, out, priority)
end

--Swim around potential prey but never too close
local function hq_reaper_circle(self, priority, speed, obj)
    local dest

    local function out()
        --make sure target is still in range
        local pos = self.object:get_pos()
        local target = obj:get_pos()
        if not mobkit.is_alive(obj) or not mobkit.isnear3d(pos, target, 128) then return true end

        --chance to attack the target suddenly (more likely if target is facing away)
        if mobkit.timer(self, 5) and mobkit.isnear3d(pos, target, 64)
        and (not obj:is_player() or math.random()*math.pi > vector.angle(pos-target, obj:get_look_dir())) then
            --not yet working correctly, so removed for now
            --note to self: switch inequality above later
            hq_reaper_grab(self, priority, 20, 0.1, obj)
            return true
        end

        --check there is a destination
        if not dest or mobkit.isnear3d(pos, dest, 6) then
            for _ = 1, 16 do
                --pick a random nearby position and check if reachable
                local new_dest = mobkit.get_node_pos(target+vector.new(math.random(-64, 64), math.random(-32, 16), math.random(-64, 64)))
                if sub_mobs.in_water(new_dest) and not mobkit.isnear3d(target, new_dest, 16) and not minetest.raycast(pos, new_dest, false):next() then
                    dest = new_dest
                    break
                end
            end
            if not dest then return end
        end

        --move towards destination
        local dir = vector.normalize(self.object:get_velocity()+vector.normalize(dest-pos)*0.5)
        self.object:set_velocity(dir*speed)
        self.object:set_rotation(mobkit.dir_to_rot(dir))
    end

    mobkit.queue_high(self, out, priority)
end

--Function controlling reapers, swim around and grab prey by surprise
local function reaper_brain(self)
    --start to circle nearby prey
    if mobkit.timer(self, 10) and mobkit.get_queue_priority(self) < 20 then
        for i, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 96)) do
            if obj:is_player() or sub_mobs.containsi(reaper_prey, obj:get_luaentity().name) then
                hq_reaper_circle(self, 20, 15, obj)
            end
        end
    end

    --swim around idly (default)
    if mobkit.is_queue_empty_high(self) then
        sub_mobs.hq_big_roam(self, 10, 15)
    end
end

--Procedurally animate reaper tail
local bone_lengths = {{"hips", 10}, {"tail", 10}, {"tail2", 5}, {"tail3", 5}, {"tail4", 5}}

local function reaper_handle_tail(self)
    if self.old_pos then
        --find position of each segment
        local rot = self.old_rot
        local pos = self.old_pos-5*mobkit.rot_to_dir(rot)
        local positions = {}
        for _, item in pairs(bone_lengths) do
            local bone, length = unpack(item)
            rot = rot+vector.apply(({self.object:get_bone_position(bone)})[2], math.rad)
            pos = pos-length*mobkit.rot_to_dir(rot)
            positions[bone] = pos
        end

        --point each bone towards its old end position
        rot = self.object:get_rotation()
        pos = self.object:get_pos()-5*mobkit.rot_to_dir(rot)
        for _, item in pairs(bone_lengths) do
            local bone, length = unpack(item)
            local new_rot = mobkit.dir_to_rot(positions[bone]-pos)
            self.object:set_bone_position(bone, vector.zero(), vector.apply(vector.subtract(new_rot, rot), math.deg))
            rot = new_rot
            pos = pos-length*mobkit.rot_to_dir(rot)
        end
    end

    --set up stuff for next iteration
    self.old_rot = self.object:get_rotation()
    self.old_pos = self.object:get_pos()
end

--Step function for reapers, processing tail movement
local function reaper_stepfunc(self, dtime, colinfo)
    mobkit.stepfunc(self, dtime, colinfo)
    --this, TOO, does not work. set_bone_position simply has no effect whatsoever
    --reaper_handle_tail(self)
end

--Reaper leviathan, found in several surface biomes which are also the most dangerous ones largely because of the reaper
minetest.register_entity("sub_mobs:reaper", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=50, y=50},
        mesh = "reaper.obj",
        textures = {"reaper.png"},
        selectionbox = {-5, -2.5, -5, 5, 2.5, 5},
        physical = false --for the same reason as the reefback
    },
    timeout = 0,
    buoyancy = 1,
    max_hp = 1000,
    max_speed = 20,
    jump_height = 0.5,
    view_range = 2,
    on_step = reaper_stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = reaper_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    attack = {
        range = 10,
        full_punch_interval = 1,
        damage_groups = {normal=16}
    }
})