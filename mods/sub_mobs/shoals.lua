--Function controlling shoals, simply swim around aimlessly
local function shoal_brain(fish_type)
    return function (self)
        if mobkit.timer(self, 1) then
            --particle spawner
            local image = "sub_mobs_"..fish_type..".png"
            local pos = self.object:get_pos()
            local diag = vector.new(2, 2, 2)
            minetest.add_particlespawner({
                amount = 50,
                time = 1,
                collisiondetection = true,
                vertical = true,
                texture = image,
                texpool = {image, image.."^[transform4"},
                glow = 15,
                exptime = 1,
                pos = {min=pos-diag, max=pos+diag},
                vel = {min=-diag, max=diag},
                size = {min=2, max=3},
                drag = 1,
                attract = {
                    kind = "point",
                    strength = 2,
                    origin = vector.zero(),
                    origin_attached = self.object,
                    die_on_contact = false
                }
            })
            --do the brain stuff
            if not sub_mobs.check_in_water(self) then return end
            if mobkit.is_queue_empty_high(self) then
                sub_mobs.hq_fish_roam(self, 10, self.max_speed)
            end
        end
    end
end

--Shoals, groups of small fish for ambience, some spawn in various biomes while others only appear on reefbacks
for _, fish_type in ipairs({"boomerang", "hoopfish"}) do
    minetest.register_entity("sub_mobs:"..fish_type.."_shoal", {
        initial_properties = {
            physical = false,
            pointable = false,
            is_visible = false --hehe they each get longer by one character
        },
        timeout = 120,
        buoyancy = 1,
        max_hp = 1,
        max_speed = 2,
        view_range = 0,
        on_activate = mobkit.actfunc,
        on_step = mobkit.stepfunc,
        get_staticdata = mobkit.statfunc,
        logic = shoal_brain(fish_type)
    })
end

sub_mobs.register_spawn({
    name = "sub_mobs:boomerang_shoal",
    biomes = {"sub_core:forest", "sub_core:grassland"},
    chance = 1,
    gen_chance = 1,
    reduction = 0.01
})

sub_mobs.register_spawn({
    name = "sub_mobs:hoopfish_shoal",
    biomes = {"sub_core:forest", "sub_core:grassland"},
    chance = 1,
    gen_chance = 1,
    reduction = 0.01
})