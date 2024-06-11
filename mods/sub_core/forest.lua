--Kelp Forest and Kelp Forest Caves biomes
sub_core.register_biome("sub_core:forest", {
    name = "Forest",
    node_top = "sub_core:sand",
    node_stone = "sub_core:sandstone",
    node_water = "sub_core:forest_water",
    heat_point = 40,
    humidity_point = 70,
    dist_point = 100,
    noise = {
        offset = -30,
        scale = 10,
        spread = {x=100, y=100, z=100},
        octaves = 4,
        persistence = 0.5,
        lacunarity = 2.0
    },
    noise3d = {
        offset = 5,
        scale = 15,
        spread = {x=40, y=40, z=40},
        octaves = 4,
        persistence = 0.5,
        lacunarity = 2.0
    }
})

sub_core.register_water("sub_core:forest_water", {
    description = "Forest Water",
    color = {r=0, g=180, b=120},
    tint = {r=0, g=60, b=40, a=150},
    fog = {
        fog_distance = 80,
        fog_start = 0.2,
        fog_color = {r=0, g=180, b=120}
    }
})

--Grass covering the floor
minetest.register_node("sub_core:forest_grass", sub_core.add_water_physics({
    description = "Forest Grass",
    drawtype = "plantlike",
    tiles = {"default_junglegrass.png"},
    inventory_image = "default_junglegrass.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0.375, 0.375}
    },
    walkable = false,
    pointable = false,
    buildable_to = true,
    groups = {attached_node=1}
}, "sub_core:forest_water"))

sub_core.register_decor({
    biome = "sub_core:forest",
    fill_ratio = 0.6,
    decor = "sub_core:forest_grass"
})

--Creepvines - the kelp-like plants which give the Kelp Forest its name
minetest.register_node("sub_core:creepvine_stem", sub_core.add_water_physics({
    description = "Creepvine Stem",
    drawtype = "plantlike",
    tiles = {"sub_core_creepvine_stem.png"},
    inventory_image = "sub_core_creepvine_stem.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375}
    },
    on_punch = sub_core.drop_if_slash("sub_core:creepvine_sample", true)
}, "sub_core:forest_water"))

minetest.register_node("sub_core:creepvine_stalk", sub_core.add_water_physics({
    description = "Creepvine Stalk",
    drawtype = "plantlike",
    tiles = {"sub_core_creepvine_stalk.png"},
    inventory_image = "sub_core_creepvine_stalk.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}
    },
    on_punch = sub_core.drop_if_slash("sub_core:creepvine_sample", true)
}, "sub_core:forest_water"))

minetest.register_node("sub_core:creepvine_with_cluster", sub_core.add_water_physics({
    description = "Creepvine with Cluster",
    drawtype = "plantlike",
    tiles = {"sub_core_creepvine_stem.png^sub_core_creepvine_cluster.png"},
    inventory_image = "sub_core_creepvine_stem.png^sub_core_creepvine_cluster.png",
    selection_box = {
        type = "fixed",
        fixed = {-0.375, -0.5, -0.375, 0.375, 0.5, 0.375}
    },
    light_source = 7,
    on_rightclick = function (pos, node, user, itemstack)
        minetest.set_node(pos, {name="sub_core:creepvine_stem"})
        return sub_core.give_item("sub_core:creepvine_seeds")(pos, node, user, itemstack)
    end,
    on_punch = sub_core.drop_if_slash("sub_core:creepvine_sample", true)
}, "sub_core:forest_water"))

minetest.register_craftitem("sub_core:creepvine_seeds", {
    description = "Creepvine Seeds",
    inventory_image = "sub_core_creepvine_cluster.png"
})

minetest.register_node("sub_core:bushy_creepvine", sub_core.add_water_physics({
    description = "Bushy Creepvine",
    drawtype = "allfaces_optional",
    use_texture_alpha = "clip",
    tiles = {"sub_core_bushy_creepvine.png"},
    on_punch = sub_core.drop_if_slash("sub_core:creepvine_sample", true)
}, "sub_core:forest_water"))

minetest.register_craftitem("sub_core:creepvine_sample", {
    description = "Creepvine Sample",
    inventory_image = "sub_core_creepvine_stalk.png"
})

--Function for spawning a creepvine at a given location
local function place_creepvine(pos)
    --make sure the position is open to the sky
    local light = minetest.get_natural_light(pos, 0.5)
    if not light or light < 15 or pos.y > -16 then
        minetest.remove_node(pos)
        return
    end
    
    --choose variant
    local rand = PcgRandom(pos.x+PcgRandom(pos.y^pos.z):next())
    local variant = rand:next(1, 4)
    local sections
    if variant == 1 then
        sections = {"sub_core:creepvine_stalk", "sub_core:bushy_creepvine", "sub_core:forest_water"}
    elseif variant == 2 then
        sections = {"sub_core:creepvine_stalk", "sub_core:creepvine_stalk", "sub_core:creepvine_stem"}
    elseif variant == 3 then
        sections = {"sub_core:creepvine_stem", "sub_core:creepvine_stem", "sub_core:creepvine_stem"}
    else
        sections = {"sub_core:creepvine_stem", "sub_core:creepvine_with_cluster", "sub_core:bushy_creepvine"}
    end

    --build each section
    local height = rand:next(pos.y+10, -1)
    local middle = rand:next((pos.y+height)*0.5, height-4)
    for y = pos.y, height do
        local node
        if y < middle then node = sections[1]
        elseif y == middle then node = sections[2]
        else node = sections[3] end
        minetest.set_node(vector.new(pos.x, y, pos.z), {name=node})
    end
end

minetest.register_node("sub_core:creepvine_spawner", {
    description = "Creepvine Spawner",
    drawtype = "airlike",
    groups = {not_in_creative_inventory=1},
    on_construct = place_creepvine
})

minetest.register_abm({
    nodenames = {"sub_core:creepvine_spawner"},
    interval = 1,
    chance = 1,
    action = place_creepvine,
})

sub_core.register_decor({
    biome = "sub_core:forest",
    fill_ratio = 0.04,
    decor = "sub_core:creepvine_spawner"
})

--Drooping stingers, spawn mostly in caves and poison the player
minetest.register_node("sub_core:drooping_stinger", {
    description = "Drooping Stinger",
    drawtype = "mesh",
    mesh = "double_plantlike_down.obj",
    tiles = {"sub_core_drooping_stinger.png"},
    use_texture_alpha = "clip",
    selection_box = {
        type = "fixed",
        fixed = {-0.25, -1.5, -0.25, 0.25, 0.5, 0.25}
    },
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    groups = {drooping_stinger=1},
    liquid_move_physics = true,
    post_effect_color = {r=60, g=120, b=0, a=100},
    _fog = {
        fog_distance = 10,
        fog_start = 0,
        fog_color = {r=192, g=255, b=0}
    }
})

minetest.register_node("sub_core:drooping_stinger_tip", {
    description = "Drooping Stinger Tip",
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    buildable_to = true,
    damage_per_second = 3,
    liquid_move_physics = true,
    post_effect_color = {r=60, g=120, b=0, a=100},
    _fog = {
        fog_distance = 10,
        fog_start = 0,
        fog_color = {r=192, g=255, b=0}
    }
})

local up = vector.new(0, 1, 0)

minetest.register_abm({
    nodenames = {"sub_core:drooping_stinger", "sub_core:drooping_stinger_tip"},
    interval = 1,
    chance = 1,
    action = function (pos, node)
        if node.name == "sub_core:drooping_stinger" and minetest.get_node(pos-up).name ~= "sub_core:drooping_stinger_tip" then
            minetest.set_node(pos-up, {name="sub_core:drooping_stinger_tip"})
        elseif node.name == "sub_core:drooping_stinger_tip" and minetest.get_node(pos+up).name ~= "sub_core:drooping_stinger" then
            minetest.set_node(pos, minetest.get_node(pos+up))
        end
    end
})

sub_core.register_decor({
    type = "bottom",
    biome = "sub_core:forest",
    fill_ratio = 0.1,
    decor = "sub_core:drooping_stinger"
})

--Various other decorations
sub_core.register_decor({
    type = "surface",
    biome = "sub_core:forest",
    fill_ratio = 0.04,
    decor = "sub_core:sandstone"
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:forest",
    fill_ratio = 0.002,
    decor = "sub_core:limestone_outcrop_spawner"
})

sub_core.register_decor({
    type = "underground",
    biome = "sub_core:forest",
    fill_ratio = 0.001,
    decor = "sub_core:sandstone_outcrop_spawner"
})

sub_core.register_schem({
    type = "surface",
    biome = "sub_core:forest",
    fill_ratio = 0.0002,
    radius = 5,
    schem = minetest.get_modpath("sub_core").."/schems/coral_tube.mts",
})

sub_core.register_decor({
    biome = "sub_core:forest",
    fill_ratio = 0.003,
    max_param2 = 4,
    decor = "sub_core:salvage1"
})