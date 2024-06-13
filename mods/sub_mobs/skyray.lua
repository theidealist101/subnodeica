--Fly around randomly in the air, based on hq_fish_roam
local function hq_air_roam(self, priority, speed)
    local dest

    local function out()
        --check there is a destination
        local pos = self.object:get_pos()
        if not dest or mobkit.isnear3d(pos, dest, 3) then
            for _ = 1, 8 do
                --pick a random nearby position and check if reachable
                dest = mobkit.get_node_pos(pos+vector.new(math.random(-32, 32), math.random(-8, 8), math.random(-32, 32)))
                if dest.y > 16 and dest.y < 32 and not minetest.raycast(pos, dest, false):next() then break end
            end
            if not dest then return end
        end

        --move towards destination
        local dir = vector.normalize(self.object:get_velocity()+vector.normalize(dest-pos)*0.1)
        self.object:set_velocity(dir*speed)
        self.object:set_rotation(mobkit.dir_to_rot(dir))
    end

    mobkit.queue_high(self, out, priority)
end

--Function controlling flying skyrays, fly around aimlessly
local function skyray_brain(self)
    if mobkit.is_queue_empty_high(self) then
        hq_air_roam(self, 10, 4)
    end
end

--Skyray, found above water in all biomes
minetest.register_entity("sub_mobs:skyray", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "skyray.obj",
        textures = {"skyray.png"},
        physical = false,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 20,
    max_speed = 10,
    jump_height = 0.5,
    view_range = 2,
    size = 1,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = skyray_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_death = sub_core.become_corpse,
    corpse_despawn = true
})

sub_mobs.register_spawn({
    name = "sub_mobs:skyray",
    nodes = {"air"},
    chance = 1,
    reduction = 0.01,
    height_min = 16,
    height_max = 32
})