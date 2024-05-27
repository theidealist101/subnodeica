--Function controlling gasopods, roaming aimlessly and ejecting gas pods when threatened
local function gasopod_brain(self)
    local pos = self.object:get_pos()

    if mobkit.timer(self, 3) then
        --release gas pods if threatened
        local player = mobkit.get_nearby_player(self)
        if player and vector.distance(pos, player:get_pos()) < 8 then
            sub_mobs.hq_fish_flee(self, 20, 3, player)
            for i = 1, 10 do
                minetest.add_entity(pos+vector.new(
                    math.random(-2, 2),
                    math.random(-2, 2),
                    math.random(-2, 2)
                ), "sub_mobs:gas_pod") --TODO: offset towards tail
            end
            minetest.add_particlespawner({
                amount = 10,
                time = 0.01,
                texture = {
                    name = "gas_particle.png",
                    alpha = 0.8,
                    scale = 10
                },
                glow = 15,
                pos = {min=pos-vector.new(1, 1, 1), max=pos+vector.new(1, 1, 1)},
                exptime = 1,
                attract = {
                    kind = "point",
                    strength = -4,
                    origin = pos
                }
            })
        end
    end

    --roam aimlessly (default)
    if mobkit.timer(self, 1) then
        if mobkit.is_queue_empty_high(self) and mobkit.is_queue_empty_low(self) and (math.abs(minetest.get_timeofday()-0.5) > 0.35 or math.random() < 0.2) then
            sub_mobs.hq_herd_roam(self, 10, 2, 0.5)
        else --TODO: not quite working yet
            mobkit.lq_idle(self, 10)
            self.object:set_velocity(vector.zero())
            self.object:set_rotation(vector.new(0, self.object:get_rotation().y, 0))
        end
    end
end

--Gasopod, almost completely in shallows, medium to large defensive herbivore
minetest.register_entity("sub_mobs:gasopod", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=20, y=20},
        mesh = "gasopod.obj",
        textures = {"gasopod.png"},
        collisionbox = {-2, 0, -2, 2, 2, 2},
        selectionbox = {-2, 0, -2, 2, 2, 2},
        physical = true,
        glow = 15
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 60,
    max_speed = 5,
    jump_height = 0.5,
    view_range = 16,
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = gasopod_brain,
    armor_groups = {
        normal = 100,
        fire = 100
    }
})

sub_mobs.register_spawn({
    name = "sub_mobs:gasopod",
    biomes = {"sub_core:shallows"},
    chance = 0.1,
    reduction = 0.1,
    count_max = 3,
    height_min = 0.5
})

--Gas pod, ejected by gasopods, explodes into gas clouds dealing poison damage
minetest.register_entity("sub_mobs:gas_pod", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "gas_pod.obj",
        textures = {"gas_pod.png"},
        collisionbox = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
        selectionbox = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
        physical = false,
        glow = 15
    },
    on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            self.timer = tonumber(staticdata)
        else
            self.timer = math.random(-5, 5)*0.1
        end
    end,
    on_step = function (self, dtime)
        self.timer = self.timer+dtime
        if self.timer >= 2 then
            minetest.add_entity(self.object:get_pos(), "sub_mobs:gas_cloud")
            self.object:remove()
        end
    end,
    on_rightclick = function (self, user)
        self.object:remove()
        user:get_inventory():add_item("main", "sub_mobs:item_gas_pod")
    end,
    get_staticdata = function (self) return tostring(self.timer) end
})

minetest.register_craftitem("sub_mobs:item_gas_pod", {
    description = "Gas Pod",
    inventory_image = "sub_mobs_gas_pod.png",
    on_place = function (itemstack, user, pointed)
        minetest.add_entity(pointed.above, "sub_mobs:gas_pod")
        itemstack:take_item()
        return itemstack
    end
})

--BUG: currently gas clouds seem to do no damage for unknown reasons
minetest.register_entity("sub_mobs:gas_cloud", {
    initial_properties = {
        visual = "sprite",
        textures = {"blank.png"},
        collisionbox = {-1.5, -1.5, -1.5, 1.5, 1.5, 1.5},
        physical = false,
        pointable = false,
    },
    on_activate = function(self, staticdata)
        if staticdata and staticdata ~= "" then
            self.timer = tonumber(staticdata)
        else
            self.timer = 0
        end
        local pos = self.object:get_pos()
        local offset = vector.new(1, 1, 1)
        minetest.add_particlespawner({
            amount = 20,
            time = 5-self.timer,
            texture = {
                name = "gas_particle.png",
                alpha = 0.8,
                scale = 10,
            },
            glow = 15,
            pos = {min=pos-offset, max=pos+offset},
            exptime = 2,
            attract = {
                kind = "point",
                strength = -0.4,
                origin = pos
            }
        })
    end,
    on_step = function (self, dtime)
        self.timer = self.timer+dtime
        if self.timer >= 5 then
            self.object:remove()
        elseif math.floor(self.timer+dtime) > math.floor(self.timer) then --based on mobkit.timer
            local pos = self.object:get_pos()
            local offset = vector.new(1.5, 1.5, 1.5)
            for i, obj in ipairs(minetest.get_objects_in_area(pos-offset, pos+offset)) do
                if obj:is_player() or obj:get_luaentity().name ~= self.name then
                    obj:punch(self.object, 1, {
                        full_punch_interval = 1,
                        damage_groups = {gas=2},
                        max_drop_level = 1,
                        groupcaps = {}
                    })
                end
            end
        end
    end,
    get_staticdata = function (self) return tostring(self.timer) end
})