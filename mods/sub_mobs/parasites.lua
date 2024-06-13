--Entities which biters and blighters will try to attack
local biter_prey = {
    "sub_mobs:spadefish",
    "sub_mobs:peeper",
    "sub_mobs:boomerang",
    "sub_mobs:gasopod",
    "sub_mobs:rabbitray"
}

--Function controlling biters and blighters, swimming around like a fish but attacking rather than fleeing
local function biter_brain(self)
    if mobkit.timer(self, 1) then
        --fall back into water if out of water
        if not sub_mobs.check_in_water(self) then return end

        --attack certain entities nearby
        for i, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 8)) do
            if obj:is_player() or sub_mobs.containsi(biter_prey, obj:get_luaentity().name) then
                while obj:get_attach() do obj = obj:get_attach() end
                sub_mobs.hq_water_chase(self, 20, 4, 0.1, obj)
            end
        end

        --swim around (default)
        if mobkit.is_queue_empty_high(self) then
            sub_mobs.hq_fish_roam(self, 10, 2)
        end
    end
end

--Biter, mainly in grassland, spawns in large packs, hostile to corpses and larger herbivores
minetest.register_entity("sub_mobs:biter", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "biter.obj",
        textures = {"biter.png"},
        collisionbox = {-0.25, -0.0625, -0.25, 0.25, 0.4375, 0.25},
        selectionbox = {-0.25, -0.0625, -0.25, 0.25, 0.4375, 0.25},
        physical = true
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 2,
    max_speed = 10,
    jump_height = 0.5,
    view_range = 2,
    size = 0.6,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = biter_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    attack = {
        range = 1,
        full_punch_interval = 1,
        damage_groups = {normal=1}
    },
    on_death = sub_core.become_corpse
})

sub_mobs.register_spawn({
    name = "sub_mobs:biter",
    biomes = {"sub_core:grassland"},
    chance = 0.1,
    reduction = 0.01,
    count = 3,
    count_max = 6
})

--Entities which mesmer will hypnotise
local mesmer_prey = {
    "sub_mobs:sandshark",
    "sub_mobs:mesmer"
}

--HUD effect given to the player by the mesmer
local mesmer_hud = {
    hud_elem_type = "image", --"type" didn't work for some reason so I had to use the deprecated version
    text = "mesmer_hud.png^[opacity:100",
    --tf do you mean you can't have animated HUDs
    --[[text = {
        name = "mesmer_hud_animated.png^[opacity:100",
        animation = {
            type = "vertical_frames",
            aspect_w = 32,
            aspect_h = 16,
            length = 0.5
        }
    },]]
    position = {x=0.5, y=0.5},
    z_index = -50, --in front of diving mask but behind hotbar
    scale = {x=-100, y=-100}
}

--Stop in place and hypnotise entity
local function hq_mesmerise(self, priority, obj)
    local player = obj:is_player()
    local hud

    local function out()
        --make sure entity is still in range
        local pos = self.object:get_pos()
        local dest = obj:get_pos()
        local dist = vector.distance(pos, dest)
        if not mobkit.is_alive(obj) or dist > 12 then
            if player and hud then obj:hud_remove(hud) end
            return true
        end

        --check if near enough to hit
        if dist < self.attack.range then
            obj:punch(self.object, 1, self.attack)
            sub_mobs.hq_fish_flee(self, priority, 5, obj)
            if player and hud then obj:hud_remove(hud) end
            return true
        end

        --stop moving and face towards victim
        self.object:set_velocity(vector.zero())
        self.object:set_rotation(mobkit.dir_to_rot(dest+vector.new(0, 1.5, 0)-pos))

        --draw in victim
        if not player then obj:set_velocity(vector.zero()) end
        obj:add_velocity(0.8*vector.direction(dest, pos))
        local dest_rot = mobkit.dir_to_rot(pos-dest-vector.new(0, 1.5, 0))
        if player then
            local rot = vector.new(obj:get_look_vertical(), obj:get_look_horizontal(), 0)
            rot = sub_mobs.turn_to(rot, dest_rot, 0.01)
            obj:set_look_vertical(rot.x)
            obj:set_look_horizontal(rot.y)
        else obj:set_rotation(sub_mobs.turn_to(obj:get_rotation(), dest_rot, 0.01)) end
        if player and not hud then hud = obj:hud_add(mesmer_hud) end
    end

    mobkit.queue_high(self, out, priority)
end

--Function controlling mesmers, swim around idly but hypnotise larger animals and each other
local function mesmer_brain(self)
    --mesmerise nearby creatures
    if mobkit.timer(self, 1) and mobkit.get_queue_priority(self) < 20 then
        for i, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 8)) do
            if obj ~= self.object and not obj:get_attach() and (obj:is_player() or sub_mobs.containsi(mesmer_prey, obj:get_luaentity().name)) then
                hq_mesmerise(self, 20, obj)
                break
            end
        end
    end

    --swim around (default)
    if mobkit.is_queue_empty_high(self) then
        sub_mobs.hq_fish_roam(self, 10, 2)
    end
end

--Mesmer, found in some deep caves, hypnotises other creatures and then bites them
minetest.register_entity("sub_mobs:mesmer", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "mesmer.obj",
        textures = {"mesmer.png"},
        collisionbox = {-0.125, 0, -0.125, 0.125, 0.25, 0.125},
        physical = true,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 4,
    max_speed = 5,
    jump_height = 0.5,
    view_range = 2,
    size = 0.5,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = mesmer_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    attack = {
        range = 2,
        full_punch_interval = 1,
        damage_groups = {normal=7}
    },
    on_death = sub_core.become_corpse
})