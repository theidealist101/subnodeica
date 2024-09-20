--Register a music track to be played depending on biome, or more specifically on water type
sub_core.registered_musics = {}

function sub_core.register_music(defs)
    defs.biomes = defs.biomes or {}
    defs.nodes = defs.nodes or {}
    defs.length = defs.length or 0
    table.insert(sub_core.registered_musics, defs)
end

minetest.register_on_mods_loaded(function()
    for _, defs in ipairs(sub_core.registered_musics) do
        for _, biome in pairs(defs.biomes) do
            local biome_defs = sub_core.registered_biomes[biome]
            if biome_defs then table.insert(defs.nodes, biome_defs.node_water) end
        end
    end
end)

--Update music per player depending on the node they're in
local music_handles = {}
local ambience_handles = {}
local water_ambience = {}
local music_defs = {}
local music_timeouts = {}

local function update_music(player, node, node_def, dtime)
    local timeout = music_timeouts[player]
    if not timeout then timeout = math.random(0, 30)
    else timeout = timeout-dtime end

    --stop track if leaving the biome
    if music_defs[player] and table.indexof(music_defs[player].nodes, node_def._water_equivalent or node) <= 0 then
        minetest.sound_fade(music_handles[player], 0.2, 0)
        music_defs[player] = nil
        timeout = math.random(0, 30)
    end

    --start a new track if necessary
    if timeout <= 0 then
        local defs
        for _ = 1, 100 do
            defs = sub_core.registered_musics[math.random(#sub_core.registered_musics)]
            if table.indexof(defs.nodes, node_def._water_equivalent or node) > 0 then break else defs = nil end
        end
        if defs then
            music_defs[player] = defs
            music_handles[player] = minetest.sound_play(defs, {to_player=player})
            timeout = defs.length+math.random(60, 120)
        else
            timeout = math.random(0, 30)
        end
    end

    music_timeouts[player] = timeout
end

local splash_counter = 0

--Update the ambient sounds depending on where the player is
local function update_ambience(player, node, node_def, dtime)
    splash_counter = splash_counter+dtime
    if node_def._water and water_ambience[player] ~= true then
        if ambience_handles[player] then
            minetest.sound_stop(ambience_handles[player])
            minetest.sound_play({name="474977-Water-Underwater-Submerge-Plunge-Hard-Rise-Instamic", gain=0.4}, {object=minetest.get_player_by_name(player)}, true)
        end
        ambience_handles[player] = minetest.sound_play({name="underwater-ambiencewav-14428", gain=0.2}, {to_player=player, loop=true})
        water_ambience[player] = true
    elseif not node_def._water and water_ambience[player] ~= false then
        if ambience_handles[player] then
            minetest.sound_stop(ambience_handles[player])
            minetest.sound_play({name="water-splash-199583", gain=0.4}, {object=minetest.get_player_by_name(player)}, true)
        end
        ambience_handles[player] = minetest.sound_play({name="gentle-ocean-waves-mix-2018-19693", gain=0.5}, {to_player=player, loop=true})
        water_ambience[player] = false
    end
end

function sub_core.update_sounds(player, node, node_def, dtime)
    update_music(player, node, node_def, dtime)
    update_ambience(player, node, node_def, dtime)
end

--Music definitions
sub_core.register_music({
    name = "drums_in_the_deep",
    gain = 0.8,
    biomes = {"sub_core:grassland"},
    length = 210
})

sub_core.register_music({
    name = "all_is_found",
    gain = 0.6,
    biomes = {"sub_core:shallows"},
    length = 220
})