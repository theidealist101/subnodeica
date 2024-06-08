--Entities which stalkers will hunt
local stalker_prey = {
    "sub_mobs:peeper",
    "sub_mobs:boomerang",
    "sub_mobs:eyeye"
}

--Function controlling stalkers, swimming around and hunting as well as playing with metal
local function stalker_brain(self)
    --fall back into water if out of water
    if not sub_mobs.check_in_water(self) then return end

    --chase prey that comes near
    if mobkit.timer(self, 10) then
        for i, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 16)) do
            if (obj:is_player() or sub_mobs.containsi(stalker_prey, obj:get_luaentity().name)) then
                sub_mobs.hq_water_chase(self, 20, 8, 0.1, obj)
            end
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
        collisionbox = {-1, -0.5, -1, 1, 0.5, 1},
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
    reduction = 0.04,
    height_max = 0.4
})