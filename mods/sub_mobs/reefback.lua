--Activation function for reefbacks, setting a random initial direction and spawning plants
local function reefback_actfunc(self, staticdata, dtime)
    sub_mobs.actfunc(self, staticdata, dtime)
    if not mobkit.recall(self, "init") then
        mobkit.remember(self, "init", true)
        self.object:set_rotation(vector.new(0, math.random()*2*math.pi, 0))
        --[[if self.name ~= "sub_mobs:reefback_baby" then
            for _ = 1, 32 do
                local obj = minetest.add_entity(self.object:get_pos(), "sub_mobs:reefback_flora", minetest.registered_nodes["sub_core:blood_grass"].tiles[1])
                local x = math.random(-14, 14)
                local y = math.random(-14, 14)
                obj:set_attach(self.object, "", 7*vector.new(x-y, 8, x+y)) --0.7 being just under sqrt(2)/2
                minetest.log(dump(obj:get_attach()))
            end
        end]]
    end
end

--Move slowly forwards, turning if obstructed
local function hq_reefback_roam(self, priority, speed)
    local function out()
        --check if obstructed by raycasting forwards
        local pos = self.object:get_pos()
        local rot = self.object:get_rotation()
        if minetest.raycast(pos, pos+64*mobkit.rot_to_dir(rot), false):next() then
            --turn away from obstruction
            if minetest.raycast(pos, pos+64*mobkit.rot_to_dir(rot+vector.new(0, 0.5, 0)), false):next() then
                self.object:set_rotation(self.object:get_rotation()+vector.new(0, -0.01, 0))
            else
                self.object:set_rotation(self.object:get_rotation()+vector.new(0, 0.01, 0))
            end
        end

        --check if colliding and go upward if so
        local vel = speed*mobkit.rot_to_dir(rot)
        if mobkit.get_terrain_height(pos, 20) then
            vel.y = 1
        end

        --move forwards
        self.object:set_velocity(vel)
    end

    mobkit.queue_high(self, out, priority)
end

--Function controlling reefbacks, mostly just slowly moving in a single direction
local function reefback_brain(self)
    --go in one direction without stopping (default)
    if mobkit.is_queue_empty_high(self) then
        hq_reefback_roam(self, 10, 1)
    end
end

--Reefback leviathan, found in many of the safer deep surface biomes
minetest.register_entity("sub_mobs:reefback", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=160, y=160},
        mesh = "reefback.obj",
        textures = {"reefback_baby.png"},
        collisionbox = {-14, 0, -14, 14, 8, 14},
        selectionbox = {-14, 0, -14, 14, 8, 14},
        physical = false --collision buggy due to enormous collision box
    },
    timeout = 1000,
    buoyancy = 1,
    max_hp = 2000,
    max_speed = 2,
    jump_height = 0.5,
    view_range = 64,
    on_step = mobkit.stepfunc,
    on_activate = reefback_actfunc,
    get_staticdata = mobkit.statfunc,
    logic = reefback_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_death = sub_core.become_corpse
})

minetest.register_entity("sub_mobs:reefback_baby", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=50, y=50},
        mesh = "reefback.obj",
        textures = {"reefback_baby.png"},
        collisionbox = {-4.375, 0, -4.375, 4.375, 2.5, 4.375},
        selectionbox = {-4.375, 0, -4.375, 4.375, 2.5, 4.375},
        physical = true
    },
    timeout = 1000,
    buoyancy = 1,
    max_hp = 2000,
    max_speed = 2,
    jump_height = 0.5,
    view_range = 64,
    on_step = mobkit.stepfunc,
    on_activate = reefback_actfunc,
    get_staticdata = mobkit.statfunc,
    logic = reefback_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_death = sub_core.become_corpse
})

sub_mobs.register_spawn({
    name = "sub_mobs:reefback",
    biomes = {"sub_core:grassland"},
    chance = 0.05,
    gen_chance = 0.3,
    reduction = 0.1,
    dist = 100,
    height_min = -40
})

sub_mobs.register_spawn({
    name = "sub_mobs:reefback_baby",
    biomes = {"sub_core:grassland"},
    chance = 0.05,
    gen_chance = 0.3,
    reduction = 0.1,
    dist = 100,
    height_min = -40
})

--Miscellaneous plants which spawn on adult reefbacks (specifically those which are naturally nodes instead)
--not yet working: offsets for attach ignored, detaches upon unloading
minetest.register_entity("sub_mobs:reefback_flora", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "plantlike.obj",
        textures = {"sub_core_blood_grass.png"},
        selectionbox = {-0.5, 0, -0.5, 0.5, 1, 0.5},
        physical = false
    },
    on_activate = function (self, staticdata)
        if staticdata and staticdata ~= "" then
            local props = self.object:get_properties()
            props.textures = {staticdata}
            self.object:set_properties(props)
        end
    end
})