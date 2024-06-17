--Entities which sandsharks will try to attack
local sandshark_prey = {
    "sub_mobs:spadefish",
    "sub_mobs:peeper",
    "sub_mobs:boomerang"
}

--Hide in ground, with only top fins visible
local function hq_sandshark_hide(self, priority, speed)
    local hidden = 0
    local dest, final_dest

    local function out()
        --check if already hidden
        local pos = self.object:get_pos()
        if hidden > 30 then
            self.object:set_pos(pos+vector.new(0, 0.75, 0))
            sub_mobs.hq_herd_roam(self, priority, speed)
            return true
        elseif hidden > 0 then
            if mobkit.timer(self, 1) then
                hidden = hidden+1
            end
            return
        end

        --find destination
        if not dest or (not final_dest and mobkit.isnear3d(pos, dest, 2)) then
            dest = mobkit.get_node_pos(pos+vector.new(math.random(-16, 16), math.random(-16, -8), math.random(-16, 16)))
            local pointed = minetest.raycast(pos, dest, false):next()
            if pointed then
                dest = pointed.under
                final_dest = true
            end

        --check if ready to hide
        elseif final_dest and mobkit.isnear3d(pos, dest, 1.5) then
            self.object:set_pos(dest+vector.new(0, -0.125, 0))
            self.object:set_velocity(vector.zero())
            self.object:set_rotation(vector.new(0, self.object:get_rotation().y, 0))
            hidden = 1
            return
        end

        --move towards destination
        local dir = vector.normalize(self.object:get_velocity()+vector.normalize(dest-pos)*0.2)
        self.object:set_velocity(dir*speed)
        self.object:set_rotation(mobkit.dir_to_rot(dir))
    end

    mobkit.queue_high(self, out, priority)
end

--Function controlling sandsharks, hiding in ground when idle and then jumping out at passing mobs
local function sandshark_brain(self)
    --chase prey that comes near - always the closest one at any given time
    if mobkit.timer(self, 5) then
        local pos = self.object:get_pos()
        local radius = (self.object:get_velocity() == vector.zero() and 8) or 32
        local target
        local dist = 1000
        for i, obj in ipairs(minetest.get_objects_inside_radius(pos, radius)) do
            if obj:is_player() or sub_mobs.containsi(sandshark_prey, obj:get_luaentity().name) then
                while obj:get_attach() do obj = obj:get_attach() end
                local new_dist = vector.distance(pos, obj:get_pos())
                if new_dist < dist then
                    target = obj
                    dist = new_dist
                end
            end
        end
        if target then
            if self.object:get_velocity() == vector.zero() then
                self.object:set_pos(pos+vector.new(0, 0.75, 0))
                self.object:set_rotation(mobkit.dir_to_rot(vector.direction(pos, target:get_pos())))
            end
            mobkit.clear_queue_high(self)
            sub_mobs.hq_water_chase(self, 20, 8, 0.1, target)
        end
    end

    --hide and wait for something to pass (default)
    if mobkit.is_queue_empty_high(self) then
        hq_sandshark_hide(self, 10, 4)
    end
end

--Sandshark, mainly in grassland, smallish ambush predator, prone to seizures
minetest.register_entity("sub_mobs:sandshark", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=15, y=15},
        mesh = "sandshark.obj",
        textures = {"sandshark.png"},
        collisionbox = {-1, -0.5, -1, 1, 1, 1},
        physical = true
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 50,
    max_speed = 10,
    jump_height = 0.5,
    view_range = 16,
    size = 4,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = sandshark_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    attack = {
        range = 2,
        full_punch_interval = 1,
        damage_groups = {normal=6}
    },
    on_punch = sub_mobs.punchfunc(1, 0.5),
    on_death = sub_core.become_corpse,
    carnivore = true
})

sub_mobs.register_spawn({
    name = "sub_mobs:sandshark",
    biomes = {"sub_core:grassland"},
    chance = 0.01,
    gen_chance = 0.5,
    reduction = 0.04,
    height_max = -50
})