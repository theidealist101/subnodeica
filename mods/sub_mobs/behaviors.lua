--Check if value in array-like table, utility function
function sub_mobs.containsi(t, k)
    for i, val in ipairs(t) do
        if k == val then return true end
    end
    return false
end

--Check if one entity has a larger size value than another
function sub_mobs.is_larger(self, obj)
    local size = (obj:is_player() and 1.5) or obj:get_luaentity().size
    return size and self.size < size
end

--Check if position in water for purposes of pathfinding
function sub_mobs.in_water(pos)
    pos = mobkit.get_node_pos(pos)
    local node_def = minetest.registered_nodes[minetest.get_node(pos).name]
    return node_def and node_def.groups.pathfind_water and node_def.groups.pathfind_water > 0
end

--Fall down if mob out of water
function sub_mobs.check_in_water(self)
    if sub_mobs.in_water(self.object:get_pos()) then
        return true
    else
        mobkit.clear_queue_high(self)
        local dir = self.object:get_velocity()+vector.new(0, sub_mobs.gravity, 0)
        self.object:set_velocity(dir)
        self.object:set_rotation(mobkit.dir_to_rot(dir))
        return false
    end
end

--Customised on_activate which makes mobs not immortal
--but WHY are they immortal? it's so stupid
function sub_mobs.actfunc(self, staticdata, dtime)
    mobkit.actfunc(self, staticdata, dtime)
    self.armor_groups.immortal = 0
	self.object:set_armor_groups(self.armor_groups)
    self.object:set_hp(self.hp)
end

--Another utility function, turns up to a certain angle
function sub_mobs.turn_to(rot, dest_rot, turn_rate)
    local diff = dest_rot-rot
    if diff.y < -math.pi then diff.y = diff.y+2*math.pi
    elseif diff.y > math.pi then diff.y = diff.y-2*math.pi end
    if vector.length(diff) < turn_rate then return dest_rot end
    return rot+turn_rate*vector.normalize(diff)
end

--Flutter around randomly underwater, mostly staying near the ground but not too close
function sub_mobs.hq_fish_roam(self, priority, speed, nopitch)
    local dest

    local function out()
        --check there is a destination
        local pos = self.object:get_pos()
        if not dest or mobkit.isnear3d(pos, dest, 3) then
            for _ = 1, 16 do
                --pick a random nearby position and check if reachable
                local new_dest = mobkit.get_node_pos(pos+vector.new(math.random(-16, 16), math.random(-16, 8), math.random(-16, 16)))
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
        if nopitch then self.object:set_rotation(vector.new(0, self.object:get_rotation().y, 0)) end
    end

    mobkit.queue_high(self, out, priority)
end

--Flutter around while generally fleeing from entity (mostly the same as above)
--The jump parameter is used by peepers to allow jumping out of water while fleeing
function sub_mobs.hq_fish_flee(self, priority, speed, obj, jump, nopitch)
    local dest

    local function out()
        --make sure it's still necessary to keep fleeing
        local pos = self.object:get_pos()
        if not mobkit.is_alive(self.object) or not mobkit.is_alive(obj) or vector.length(pos-obj:get_pos()) > 16 then return true end

        if not dest or mobkit.isnear3d(pos, dest, 3) then
            for _ = 1, 16 do
                local new_dest = mobkit.get_node_pos(pos+12*vector.normalize(pos-obj:get_pos())+vector.new(math.random(-8, 8), math.random(-8, 8), math.random(-8, 8)))
                if (jump or sub_mobs.in_water(new_dest)) and not minetest.raycast(pos, new_dest, false):next() then
                    dest = new_dest
                    break
                end
            end
            if not dest then return end
        end

        local dir = vector.normalize(self.object:get_velocity()+vector.normalize(dest-pos)*0.2)
        self.object:set_velocity(dir*speed)
        self.object:set_rotation(mobkit.dir_to_rot(dir))
        if nopitch then self.object:set_rotation(vector.new(0, self.object:get_rotation().y, 0)) end
    end

    mobkit.queue_high(self, out, priority)
end

--Swim around randomly underwater, weighted towards other herd members (again mostly the same as above)
function sub_mobs.hq_herd_roam(self, priority, speed, herd_weight)
    if not herd_weight then herd_weight = 0 end
    local dest, herd_center

    local function out()
        if mobkit.timer(self, 1) and math.random() < 0.05 then return true end --to allow certain other behaviors
        local pos = self.object:get_pos()

        if not herd_center or mobkit.timer(self, 1) then
            --find center of all nearby entities of same type
            herd_center = pos
            local n = 1
            for i, obj in ipairs(minetest.get_objects_inside_radius(pos, 32)) do
                if not obj:is_player() and obj:get_luaentity().name == self.name then
                    herd_center = herd_center+obj:get_pos()
                    n = n+1
                end
            end
            herd_center = herd_center/n
        end

        if not dest or mobkit.isnear3d(pos, dest, 3) then
            for _ = 1, 16 do
                local new_dest = mobkit.get_node_pos(pos+herd_weight*(herd_center-pos)+vector.new(math.random(-32, 32), math.random(-16, 32), math.random(-32, 32)))
                if sub_mobs.in_water(new_dest) and not minetest.raycast(pos, new_dest, false):next() then
                    dest = new_dest
                    break
                end
            end
            if not dest then return end
        end

        local dir = vector.normalize(self.object:get_velocity()+vector.normalize(dest-pos)*0.04)
        self.object:set_velocity(dir*speed)
        self.object:set_rotation(mobkit.dir_to_rot(dir))
    end

    mobkit.queue_high(self, out, priority)
end

--Swim towards entity and attack it
function sub_mobs.hq_water_chase(self, priority, speed, turn_rate, obj)
    local function out()
        --make sure the entity is still alive
        if not mobkit.exists(self) or not mobkit.is_alive(obj) then return true end

        --turn towards entity
        local pos = self.object:get_pos()
        local dest = obj:get_pos()
        local rot = self.object:get_rotation()
        self.object:set_rotation(sub_mobs.turn_to(rot, mobkit.dir_to_rot(dest-pos), turn_rate))

        --try to attack entity
        if self.attack and mobkit.isnear3d(pos, dest, self.attack.range) then
            obj:punch(self.object, 1, self.attack)
            return true
        end

        --move forwards
        self.object:set_velocity(speed*mobkit.rot_to_dir(rot))
    end

    mobkit.queue_high(self, out, priority)
end

--Create an explosion, dealing damage to nearby entities and spawning lots of particles
function sub_mobs.explode(origin, pos)
    if not pos then pos = origin.object:get_pos() end
    local range = origin.explosion.range
    for i, obj in ipairs(minetest.get_objects_inside_radius(pos, range)) do
        if obj ~= origin then
            obj:punch(origin.object, 1-vector.distance(pos, obj:get_pos())/range, origin.explosion)
        end
    end
    local offset = vector.new(1, 1, 1)
    minetest.add_particlespawner({
        amount = 100,
        time = 0.1,
        texture = {
            name = "explosion.png",
            alpha = 0.5,
            scale = 10,
        },
        pos = {min=pos-offset, max=pos+offset},
        exptime = 2,
        attract = {
            kind = "point",
            strength = -1,
            origin = pos
        }
    })
end