--Entities which stalkers will hunt
local stalker_prey = {
    "sub_mobs:peeper",
    "sub_mobs:boomerang",
    "sub_mobs:eyeye"
}

--Utility function for dropping held item
local item_size = minetest.registered_entities["__builtin:item"].initial_properties.visual_size
local held_item_size = {x=item_size.x*0.1, y=item_size.y*0.1}

local function drop_items(self)
    for i, obj in ipairs(self.object:get_children()) do
        obj:set_detach()
        obj:set_properties({visual_size=item_size})
    end
end

--Swim towards and pick up dropped item (based on hq_water_chase)
local function hq_item_pickup(self, priority, speed, turn_rate, obj)
    local function out()
        --make sure the item still exists and is not picked up
        if not mobkit.exists(obj) or obj:get_attach() then return true end

        --turn towards item
        local pos = self.object:get_pos()
        local dest = obj:get_pos()
        local rot = self.object:get_rotation()
        self.object:set_rotation(sub_mobs.turn_to(rot, mobkit.dir_to_rot(dest-pos), turn_rate))

        --try to pick up item
        if self.attack and mobkit.isnear3d(pos, dest, self.attack.range+0.5) then
            obj:set_attach(self.object, "", {x=0, y=0, z=1.5}, {x=0, y=0, z=0}, false)
            obj:set_properties({visual_size=held_item_size})
            return true
        end

        --move forwards
        self.object:set_velocity(speed*mobkit.rot_to_dir(rot))
    end

    mobkit.queue_high(self, out, priority)
end

--Function controlling stalkers, swimming around and hunting as well as playing with metal
local function stalker_brain(self)
    --fall back into water if out of water
    if not sub_mobs.check_in_water(self) then return end

    --pick up nearby metal
    if mobkit.timer(self, 5) then
        for i, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 32)) do
            local luaentity = obj:get_luaentity()
            if luaentity and luaentity.name == "__builtin:item" and luaentity.itemstring ~= "" and not obj:get_attach() then
                local defs = minetest.registered_items[string.split(luaentity.itemstring, " ")[1]]
                if defs and defs.groups.metal and defs.groups.metal > 0 then
                    hq_item_pickup(self, 30, 6, 0.1, obj)
                    return
                end
            end
        end
    end

    --chase prey that comes near
    if mobkit.timer(self, 10) and mobkit.get_queue_priority(self) < 20 then
        for i, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 16)) do
            if obj:is_player() or sub_mobs.containsi(stalker_prey, obj:get_luaentity().name) then
                drop_items(self)
                sub_mobs.hq_water_chase(self, 20, 8, 0.1, obj)
            end
        end

        --chance to drop held item
        if math.random() < 0.2 then
            drop_items(self)
        end
    end

    --swim around idly (default)
    if mobkit.is_queue_empty_high(self) then
        sub_mobs.hq_herd_roam(self, 10, 5, 10)
    end
end

--Stalker, mainly in forest, smallish stealth/pack predator, loves metal
minetest.register_entity("sub_mobs:stalker", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "stalker.obj",
        textures = {"stalker.png"},
        collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
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
    logic = stalker_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    attack = {
        range = 1.5,
        full_punch_interval = 1,
        damage_groups = {normal=6}
    }
})

sub_mobs.register_spawn({
    name = "sub_mobs:stalker",
    biomes = {"sub_core:forest"},
    chance = 0.1,
    reduction = 0.04
})