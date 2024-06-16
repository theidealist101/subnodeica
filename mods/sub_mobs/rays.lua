--Function controlling rays, swim around aimlessly without fleeing from anything
local function ray_brain(self)
    if mobkit.timer(self, 1) then
        --fall back into water if out of water
        if not sub_mobs.check_in_water(self) then return end

        --swim around (default)
        if mobkit.is_queue_empty_high(self) then
            sub_mobs.hq_herd_roam(self, 10, self.max_speed*0.3, 0)
        end
    end
end

--Rabbit ray, mostly shallows and forest, quite small
minetest.register_entity("sub_mobs:rabbitray", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "rabbitray.obj",
        textures = {"rabbitray.png"},
        collisionbox = {-0.5, -0.0625, -0.5, 0.5, 0.1875, 0.5},
        physical = true,
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
    logic = ray_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_core.become_corpse
})

sub_mobs.register_spawn({
    name = "sub_mobs:rabbitray",
    biomes = {"sub_core:shallows", "sub_core:forest"},
    chance = 0.4,
    reduction = 0.05
})