--All small fish that can be picked up by the player

--Basic function controlling small fish, but with a few more complex behaviours for certain species
local function smallfish_brain(self)
    if mobkit.timer(self, 1) then
        --fall back into water if out of water
        if sub_mobs.check_in_water(self) then
            --swim away from larger entities nearby
            for i, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 8)) do
                if self:flee_check(obj) then
                    sub_mobs.hq_fish_flee(self, 20, self.max_speed*0.5, obj, self.name == "sub_mobs:peeper", self.name == "sub_mobs:hoverfish")
                end
            end

            --swim around (default)
            if mobkit.is_queue_empty_high(self) then
                sub_mobs.hq_fish_roam(self, 10, self.max_speed*0.3, self.name == "sub_mobs:hoverfish")
            end
        end
    end
end

--Functions for picking up and placing a small fish
local function smallfish_pick(name)
    local function out(self, user)
        self.object:remove()
        user:get_inventory():add_item("main", name)
    end
    return out
end

local function smallfish_place(name)
    local function out(itemstack, user, pointed)
        --deal with both pointed_thing and pos
        if pointed.type == "node" then
            pointed = pointed.above
        else
            local pos = user:get_pos()+vector.new(0, 1.625, 0)
            local ray = minetest.raycast(pos, pos+4*user:get_look_dir())
            ray:next() --discard the player
            pointed = ray:next()
            pointed = pointed and minetest.get_pointed_thing_position(pointed, true) or pos+2*user:get_look_dir()
        end
        minetest.add_entity(pointed, name)
        itemstack:take_item()
        return itemstack
    end
    return out
end

--Peeper, spawns in most biomes, quite large and fast, can jump briefly out of the water
minetest.register_entity("sub_mobs:peeper", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "peeper.obj",
        textures = {"peeper.png"},
        collisionbox = {-0.25, -0.0625, -0.25, 0.25, 0.4375, 0.25},
        selectionbox = {-0.25, -0.0625, -0.25, 0.25, 0.4375, 0.25},
        physical = true,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 4,
    max_speed = 10,
    jump_height = 0.5,
    view_range = 2,
    size = 0.5,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_peeper"),
    flee_check = sub_mobs.is_larger,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Peeper (RMB)"
})

minetest.register_craftitem("sub_mobs:item_peeper", {
    description = "Peeper",
    inventory_image = "sub_mobs_peeper.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:peeper"),
    on_use = sub_core.item_eat(20, -15)
})

sub_mobs.register_spawn({
    name = "sub_mobs:peeper",
    biomes = {"sub_core:shallows", "sub_core:forest", "sub_core:grassland"},
    chance = 1,
    gen_chance = 1,
    reduction = 0.01
})

--Bladderfish, mainly in the shallows, slow and stupid
minetest.register_entity("sub_mobs:bladderfish", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "bladderfish.obj",
        textures = {"bladderfish.png"},
        collisionbox = {-0.25, -0.1875, -0.25, 0.25, 0.375, 0.25},
        selectionbox = {-0.25, -0.0625, -0.25, 0.25, 0.4375, 0.25},
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
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_bladderfish"),
    flee_check = sub_mobs.is_larger,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Bladderfish (RMB)"
})

minetest.register_craftitem("sub_mobs:item_bladderfish", {
    description = "Bladderfish",
    inventory_image = "sub_mobs_bladderfish.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:bladderfish"),
    on_use = sub_core.item_eat(9, -4, 15)
})

sub_mobs.register_spawn({
    name = "sub_mobs:bladderfish",
    biomes = {"sub_core:shallows"},
    chance = 1,
    gen_chance = 1,
    reduction = 0.01
})

--Boomerang, spawns in most biomes, small but fast
minetest.register_entity("sub_mobs:boomerang", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "boomerang.obj",
        textures = {"boomerang.png"},
        collisionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
        selectionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
        physical = true,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 4,
    max_speed = 8,
    jump_height = 0.5,
    view_range = 2,
    size = 0.5,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_boomerang"),
    flee_check = sub_mobs.is_larger,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Boomerang (RMB)"
})

minetest.register_craftitem("sub_mobs:item_boomerang", {
    description = "Boomerang",
    inventory_image = "sub_mobs_boomerang.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:boomerang"),
    on_use = sub_core.item_eat(12, -8)
})

sub_mobs.register_spawn({
    name = "sub_mobs:boomerang",
    biomes = {"sub_core:shallows", "sub_core:forest", "sub_core:grassland"},
    chance = 1,
    gen_chance = 1,
    reduction = 0.01
})

--Garryfish, not so common, slow and stupid, kinda derpy looking
minetest.register_entity("sub_mobs:garryfish", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "garryfish.obj",
        textures = {"garryfish.png"},
        collisionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
        selectionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
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
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_garryfish"),
    flee_check = function () return false end, --garryfish ignore predators and the player
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Garryfish (RMB)"
})

minetest.register_craftitem("sub_mobs:item_garryfish", {
    description = "Garryfish",
    inventory_image = "sub_mobs_garryfish.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:garryfish"),
    on_use = sub_core.item_eat(12, -12)
})

sub_mobs.register_spawn({
    name = "sub_mobs:garryfish",
    biomes = {"sub_core:shallows"},
    chance = 0.4,
    gen_chance = 0.4,
    reduction = 0.05
})

--Spadefish, especially common in grassland, can only see above itself
minetest.register_entity("sub_mobs:spadefish", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "spadefish.obj",
        textures = {"spadefish.png"},
        collisionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
        selectionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
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
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_spadefish"),
    flee_check = function (self, obj)
        return sub_mobs.is_larger(self, obj) and obj:get_pos().y > self.object:get_pos().y
    end,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Spadefish (RMB)"
})

minetest.register_craftitem("sub_mobs:item_spadefish", {
    description = "Spadefish",
    inventory_image = "sub_mobs_spadefish.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:spadefish"),
    on_use = sub_core.item_eat(13, -6)
})

sub_mobs.register_spawn({
    name = "sub_mobs:spadefish",
    biomes = {"sub_core:grassland"},
    chance = 1,
    gen_chance = 1,
    reduction = 0.01
})

--Hoopfish, found in many biomes, slow and stupid
minetest.register_entity("sub_mobs:hoopfish", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "hoopfish.obj",
        textures = {"hoopfish.png"},
        collisionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
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
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_hoopfish"),
    flee_check = function () return false end, --similarly to garryfish
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Hoopfish (RMB)"
})

minetest.register_craftitem("sub_mobs:item_hoopfish", {
    description = "Hoopfish",
    inventory_image = "sub_mobs_hoopfish.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:hoopfish"),
    on_use = sub_core.item_eat(12, -6)
})

sub_mobs.register_spawn({
    name = "sub_mobs:hoopfish",
    biomes = {"sub_core:forest", "sub_core:grassland"},
    chance = 0.6,
    gen_chance = 0.6,
    reduction = 0.04
})

--Hoverfish, pretty much only in forest, quite large and very slow
minetest.register_entity("sub_mobs:hoverfish", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "hoverfish.obj",
        textures = {"hoverfish.png"},
        collisionbox = {-0.5, -0.125, -0.5, 0.5, 0.125, 0.5},
        physical = true,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 6,
    max_speed = 2,
    jump_height = 0.5,
    view_range = 2,
    size = 0.5,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_hoverfish"),
    flee_check = function () return false end, --similarly to garryfish
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Hoverfish (RMB)"
})

minetest.register_craftitem("sub_mobs:item_hoverfish", {
    description = "Hoverfish",
    inventory_image = "sub_mobs_hoverfish.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:hoverfish"),
    on_use = sub_core.item_eat(13, -9)
})

sub_mobs.register_spawn({
    name = "sub_mobs:hoverfish",
    biomes = {"sub_core:forest"},
    chance = 1,
    gen_chance = 1,
    reduction = 0.04
})

--Eyeye, found in deeper lush biomes, occasionally stops to look around (not implemented yet)
minetest.register_entity("sub_mobs:eyeye", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "eyeye.obj",
        textures = {"eyeye.png"},
        collisionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
        physical = true,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 6,
    max_speed = 5,
    jump_height = 0.5,
    view_range = 2,
    size = 0.5,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_eyeye"),
    flee_check = sub_mobs.is_larger,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Eyeye (RMB)"
})

minetest.register_craftitem("sub_mobs:item_eyeye", {
    description = "Eyeye",
    inventory_image = "sub_mobs_eyeye.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:eyeye"),
    on_use = sub_core.item_eat(10, 0)
})

sub_mobs.register_spawn({
    name = "sub_mobs:eyeye",
    biomes = {"sub_core:forest"},
    chance = 0.5,
    gen_chance = 0.5,
    reduction = 0.01
})

--Reginald, found mostly in deeper areas, fast but very filling
minetest.register_entity("sub_mobs:reginald", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "reginald.obj",
        textures = {"reginald.png"},
        collisionbox = {-0.375, -0.375, -0.375, 0.375, 0.3125, 0.375},
        physical = true,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 6,
    max_speed = 8,
    jump_height = 0.5,
    view_range = 2,
    size = 0.5,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = smallfish_brain,
    on_rightclick = smallfish_pick("sub_mobs:item_reginald"),
    flee_check = sub_mobs.is_larger,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_mobs.deathfunc,
    corpse_despawn = true,
    _hovertext = "Pick up Reginald (RMB)"
})

minetest.register_craftitem("sub_mobs:item_reginald", {
    description = "Reginald",
    inventory_image = "sub_mobs_reginald.png",
    stack_max = 1,
    on_drop = smallfish_place("sub_mobs:reginald"),
    on_use = sub_core.item_eat(25, -10)
})

sub_mobs.register_spawn({
    name = "sub_mobs:reginald",
    biomes = {"sub_core:grassland"},
    chance = 0.5,
    gen_chance = 0.5,
    reduction = 0.01
})

--If you found this by looking in the code, please don't tell everyone.
--Let them find it out themselves. It's funnier that way.
local function peeper_leviathan_brain(self)
    if mobkit.timer(self, 30) then
        for i, obj in ipairs(minetest.get_connected_players()) do
            obj:set_hp(0)
            minetest.chat_send_all(minetest.colorize("#ff0000", obj:get_player_name().." challenged the Peeper Leviathan and was annihilated"))
        end
    end
end

minetest.register_entity("sub_mobs:peeper_leviathan", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=1000, y=1000},
        mesh = "peeper.obj",
        textures = {"peeper.png^[colorizehsl:0:50:0"},
        physical = false,
        pointable = false,
        glow = 15
    },
    timeout = 0,
    buoyancy = 1,
    max_hp = 1000000000,
    max_speed = 10,
    jump_height = 0.5,
    view_range = 2,
    size = 1000000000,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = peeper_leviathan_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    }
})