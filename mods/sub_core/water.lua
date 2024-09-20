--Make a node def act as if waterlogged
function sub_core.add_water_physics(t, water)
    local water_defs = minetest.registered_nodes[water]
    local out = {}
    for key, value in pairs(t) do out[key] = value end
    out.paramtype = "light"
    out.sunlight_propagates = true
    out.walkable = false
    out.liquid_move_physics = true
    out.post_effect_color = water_defs.post_effect_color
    out._suspension_color = water_defs._suspension_color
    out.groups = out.groups or {}
    out.groups.pathfind_water = out.groups.pathfind_water or 1
    out._fog = water_defs._fog
    out._water = water_defs._water
    out._water_equivalent = water
    out.drowning = 1
    return out
end

--Get name of waterlogged node from basic node and water names
function sub_core.get_waterlogged(node, water)
    local names = string.split(node, ":")
    local biome = string.split(water, ":")[2]
    return names[1]..":"..string.sub(biome, 1, string.len(biome)-5)..names[2]
end

--Register a biome-specific type of "water". This is NOT a liquid!
sub_core.registered_waters = {}

function sub_core.register_water(name, defs)
    --do defaults
    local desc = defs.description or ""
    local color = defs.color or {r=255, g=255, b=255}
    local tint = defs.tint or {r=255, g=255, b=255, a=0}
    local suspension_color = minetest.colorspec_to_colorstring(defs.suspension_color or defs.color)
    local groups = defs.groups or {}
    groups.water = groups.water or 1
    groups.pathfind_water = groups.pathfind_water or 1
    local fog = defs.fog

    --register surface node
    minetest.register_node(name.."_surface", {
        description = desc.." Surface",
        drawtype = "nodebox",
        waving = 3,
        tiles = {
            {
                name = "default_water_source_animated.png",
                animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length=2.0},
                backface_culling = false
            },
            "blank.png",
            "blank.png",
            "blank.png",
            "blank.png",
            "blank.png"
        },
        inventory_image = "default_water.png",
        nodebox = {type="regular"},
        use_texture_alpha = "blend",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        pointable = false,
        diggable = false,
        buildable_to = true,
        floodable = true,
        liquid_move_physics = true,
        is_ground_content = false,
        color = color,
        post_effect_color = tint,
        groups = groups,
        sounds = {footstep={name="zapsplat_nature_water_deep_step_into_splash_85050", gain=0.1}},
        _fog = fog,
        _water = true,
        _water_equivalent = name,
        _suspension_color = suspension_color,
        drowning = 1
    })

    --register underwater node
    minetest.register_node(name, {
        description = desc,
        drawtype = "airlike",
        inventory_image = "default_water.png",
        paramtype = "light",
        sunlight_propagates = true,
        walkable = false,
        pointable = false,
        diggable = false,
        buildable_to = true,
        floodable = true,
        liquid_move_physics = true,
        is_ground_content = false,
        color = color,
        post_effect_color = tint,
        groups = groups,
        sounds = {footstep={name="zapsplat_nature_water_underwater_pass_by_swim_scuba_diver_bubbles_001_96969", gain=0.1}},
        _fog = fog,
        _water = true,
        _water_equivalent = name,
        _suspension_color = suspension_color,
        drowning = 1
    })

    --Add to table of water types
    sub_core.registered_waters[name] = defs
    for node, node_defs in pairs(sub_core.registered_waterloggables) do
        minetest.register_node(
            sub_core.get_waterlogged(node, name),
            sub_core.add_water_physics(node_defs, name)
        )
    end
end

--Register a node to be "waterloggable"
--Each combination of water and waterloggable node will be its own registered node
sub_core.registered_waterloggables = {}

function sub_core.register_waterloggable(name, defs)
    for water, water_defs in pairs(sub_core.registered_waters) do
        minetest.register_node(
            sub_core.get_waterlogged(name, water),
            sub_core.add_water_physics(defs, water)
        )
    end
    sub_core.registered_waterloggables[name] = defs
end

local air_def = minetest.registered_nodes["air"]
local diag = vector.new(1, 1, 1)

--Make player see fog as defined by the node their eyes are in (TODO: make it biome instead, when biome smoothing added?)
local function update_fog(player, node_def, pos)
    if node_def and node_def._fog then
        local light = minetest.get_natural_light(pos)/15
        local color = {
            r=node_def._fog.fog_color.r*light,
            g=node_def._fog.fog_color.g*light,
            b=node_def._fog.fog_color.b*light
        }
        player:set_sky({
            type = "plain",
            base_color = color,
            clouds = false,
            fog = {
                fog_distance=node_def._fog.fog_distance,
                fog_start=node_def._fog.fog_start,
                fog_color=color
            }
        })
        player:set_sun({visible=false, sunrise_visible=false})
        player:set_moon({visible=false})
        player:set_stars({visible=false})
    else
        player:set_sky()
        player:set_sun()
        player:set_moon()
        player:set_stars()
    end
end

local suspension_particles = {}

local function update_suspension(player, node_def, pos)
    if node_def._water_equivalent and not suspension_particles[player] then
        local max_pos = pos+32*diag
        max_pos.y = math.min(max_pos.y, 0)
        suspension_particles[player] = minetest.add_particlespawner({
            time = 1,
            amount = 200,
            --playername = player,
            texture = "suspension_particle.png^[colorize:"..node_def._suspension_color..":128",
            pos = {min=pos-32*diag, max=max_pos},
            vel = {min=-0.1*diag, max=0.1*diag},
            exptime = 10
        })
        minetest.after(1, function() suspension_particles[player] = nil end)
    end
end

minetest.register_globalstep(function(dtime)
    for i, player in ipairs(minetest.get_connected_players()) do
        local eye_pos = vector.round(player:get_pos()+vector.new(0, 1.625, 0)+0.1*player:get_eye_offset())
        local nodename = minetest.get_node(eye_pos).name
        local node_def = minetest.registered_nodes[nodename]
        local playername = player:get_player_name()
        update_fog(player, node_def, eye_pos)
        update_suspension(playername, node_def, eye_pos+player:get_velocity())
        sub_core.update_sounds(playername, nodename, node_def, dtime)
    end
end)