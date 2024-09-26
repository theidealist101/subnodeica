--Sulfur plant, spawns in shallows caves
sub_core.register_waterloggable("sub_mobs:sulfur_plant", {
    description = "Sulfur Plant",
    drawtype = "mesh",
    mesh = "sulfur_plant.obj",
    tiles = {"sulfur_plant.png"},
    use_texture_alpha = "clip",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0, 0.375}
    },
    paramtype2 = "wallmounted",
    groups = {sulfur_plant=1},
    _hovertext = "Sulfur Plant"
})

sub_core.register_waterloggable("sub_mobs:sulfur_plant_open", {
    description = "Open Sulfur Plant",
    drawtype = "mesh",
    mesh = "sulfur_plant_open.obj",
    tiles = {"sulfur_plant.png"},
    use_texture_alpha = "clip",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0, 0.375}
    },
    paramtype2 = "wallmounted",
    groups = {not_in_creative_inventory=1},
    on_timer = function (pos)
        local node = minetest.get_node(pos)
        node.name = sub_core.get_waterlogged("sub_mobs:sulfur_plant", minetest.registered_nodes[node.name]._water_equivalent)
        minetest.swap_node(pos, node)
    end,
    _hovertext = "Sulfur Plant"
})

minetest.register_abm({
    nodenames = {"group:sulfur_plant"},
    interval = 1,
    chance = 1,
    min_y = -200,
    max_y = 0,
    action = function (pos, node)
        for i, obj in ipairs(minetest.get_objects_inside_radius(pos, 8)) do
            if obj:is_player() then
                minetest.add_entity(pos, "sub_mobs:crashfish"):get_luaentity().target = obj
                node.name = sub_core.get_waterlogged("sub_mobs:sulfur_plant_open", minetest.registered_nodes[node.name]._water_equivalent)
                minetest.swap_node(pos, node)
                minetest.get_node_timer(pos):set(600, 0)
            end
        end
    end
})

sub_core.register_spawner("sub_mobs:sulfur_plant", "sub_core:sandstone_with_lichen", "sub_core:sandstone", {
    description = "Sulfur Plant Spawner",
    tiles = {"default_sandstone.png^sub_core_lichen.png"}
})

--Function controlling crashfish, swim quickly at the target then blow up
local function crashfish_brain(self)
    --check there is a target
    local pos = self.object:get_pos()
    if not self.target then
        for i, obj in ipairs(minetest.get_objects_inside_radius(pos, 64)) do
            if obj:is_player() then
                while obj:get_attach() do obj = obj:get_attach() end
                self.target = obj
                break
            end
        end
    end
    if not self.target then self.object:remove() return end

    --explode if near target or run out of time
    if self.time_total > 5 or vector.distance(pos, self.target:get_pos()) < 0.8 then
        sub_mobs.explode(self)
        self.object:remove()
        return
    end

    --swim towards target
    if mobkit.is_queue_empty_high(self) then
        sub_mobs.hq_water_chase(self, 10, 6, 0.1, self.target)
    end
end

--Crashfish, only spawned from sulfur plants in shallows, swims towards player and explodes on contact
minetest.register_entity("sub_mobs:crashfish", {
    initial_properties = {
        visual = "mesh",
        visual_size = {x=10, y=10},
        mesh = "crashfish.obj",
        textures = {"crashfish.png"},
        collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
        selectionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
        physical = true
    },
    timeout = 300,
    buoyancy = 1,
    max_hp = 5,
    max_speed = 5,
    jump_height = 0.5,
    view_range = 2,
    size = 100, --everything flees from a crashfish
    on_step = mobkit.stepfunc,
    on_activate = sub_mobs.actfunc,
    get_staticdata = mobkit.statfunc,
    logic = crashfish_brain,
    armor_groups = {
        normal = 100,
        gas = 100,
        fire = 100
    },
    explosion = {
        range = 3,
        full_punch_interval = 1,
        damage_groups = {normal=8}
    },
    on_punch = sub_mobs.punchfunc(0.5, 0.5),
    on_death = sub_core.deathfunc,
    carnivore = true --so it doesn't leave a corpse when it explodes
})