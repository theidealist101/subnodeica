--Defaults for stats (how many seconds it takes each one to run out)
sub_core.max_hunger = 3000
sub_core.max_thirst = 2000
sub_core.max_breath = 45

--HUDs for each player
local hunger_huds = {}
local hunger_huds2 = {}
local thirst_huds = {}
local drown_huds = {}
local depth_huds = {}

local hunger_hud_defs = {
    hud_elem_type = "statbar",
    position = {x=0.5, y=1},
    size = {x=24, y=24},
    alignment = {x=-1, y=-1},
    offset = {x=-265, y=-115},
    text = "stamina_hud_fg.png",
    number = 20
}

local hunger_hud_defs2 = {
    hud_elem_type = "statbar",
    position = {x=0.5, y=1},
    size = {x=24, y=24},
    alignment = {x=-1, y=-1},
    offset = {x=-265, y=-135},
    text = "stamina_hud_fg.png",
    number = 0
}

local thirst_hud_defs = {
    hud_elem_type = "statbar",
    position = {x=0.5, y=1},
    size = {x=24, y=24},
    alignment = {x=-1, y=-1},
    offset = {x=24, y=-115},
    text = "sub_core_thirst_hud.png",
    number = 20
}

local drown_hud_defs = {
    hud_elem_type = "image",
    text = "sub_core_fade_hud.png^[opacity:0",
    position = {x=0.5, y=0.5},
    z_index = 1000,
    scale = {x=-100, y=-100}
}

local depth_hud_defs = {
    hud_elem_type = "text",
    position = {x=0.5, y=0},
    offset = {x=0, y=32},
    scale = {x=100, y=100},
    size = {x=3, y=3},
    style = 4,
    number = 0x9ffeff,
    text = "0m"
}

--Functions for adding to stats
function sub_core.do_item_eat(food, water, itemstack, user)
    local meta = user:get_meta()
    local hunger = meta:get_int("hunger")
    local thirst = meta:get_int("thirst")
    local used = false
    if food ~= 0 and hunger < sub_core.max_hunger*0.95 then
        meta:set_int("hunger", hunger+food*sub_core.max_hunger*0.01)
        used = true
    end
    if water ~= 0 and thirst < sub_core.max_thirst*0.95 then
        meta:set_int("thirst", math.min(thirst+water*sub_core.max_thirst*0.01, sub_core.max_thirst))
        used = true
    end
    if used then itemstack:take_item() end
    return itemstack
end

function sub_core.item_eat(food, water)
    return function (itemstack, user)
        return sub_core.do_item_eat(food, water, itemstack, user)
    end
end

--Give player correct armor groups and stuff
minetest.register_on_joinplayer(function(player)
    player:set_armor_groups({
        normal = 100,
        gas = 100,
        fire = 100
    })
    local meta = player:get_meta()
    if not meta:contains("hunger") then meta:set_float("hunger", sub_core.max_hunger) end
    if not meta:contains("thirst") then meta:set_float("thirst", sub_core.max_thirst) end
    local name = player:get_player_name()
    hunger_huds[name] = player:hud_add(hunger_hud_defs)
    hunger_huds2[name] = player:hud_add(hunger_hud_defs2)
    thirst_huds[name] = player:hud_add(thirst_hud_defs)
    depth_huds[name] = player:hud_add(depth_hud_defs)
    if drown_huds[name] then --in case the player died of drowning
        player:hud_remove(drown_huds[name])
    end
    if meta:get_float("drown_progress") > 4 then meta:set_float("drown_progress", 4) end
    drown_huds[name] = player:hud_add(drown_hud_defs)
    local props = player:get_properties()
    props.breath_max = 45
    player:set_properties(props)
    player:set_breath(meta:get("breath") or 45)
    player:hud_set_flags({
        minimap = false,
        basic_debug = false
    })
end)

--Update stats each tick
minetest.register_globalstep(function(dtime)
    for i, obj in ipairs(minetest.get_connected_players()) do
        local meta = obj:get_meta()
        local name = obj:get_player_name()

        --update hunger
        local hunger = meta:get_float("hunger")
        if hunger <= 0 then
        else
            obj:hud_change(hunger_huds[name], "number", math.min(math.ceil(hunger*20/sub_core.max_hunger), 20))
            obj:hud_change(hunger_huds2[name], "number", math.max(math.ceil(hunger*20/sub_core.max_hunger)-20, 0))
            meta:set_float("hunger", hunger-dtime)
        end

        --update thirst
        local thirst = meta:get_float("thirst")
        if thirst <= 0 then
        else
            obj:hud_change(thirst_huds[name], "number", math.ceil(thirst*20/sub_core.max_thirst))
            meta:set_float("thirst", thirst-dtime)
        end

        --update breath
        local eye_pos = obj:get_pos()+vector.new(0, 1.625, 0)
        eye_pos.x = math.round(eye_pos.x)
        eye_pos.y = math.round(eye_pos.y)
        eye_pos.z = math.round(eye_pos.z)
        local node_def = minetest.registered_nodes[minetest.get_node(eye_pos).name]
        local breath = obj:get_breath()
        if node_def and node_def.drowning and node_def.drowning > 0 then
            if breath <= 0 then
                meta:set_float("drown_progress", meta:get_float("drown_progress")+dtime)
                if meta:get_float("drown_progress") > 8 then
                    obj:set_hp(0, "drown")
                end
            end
        else
            meta:set_float("drown_progress", math.max(meta:get_float("drown_progress")-2*dtime, 0))
            obj:set_breath(breath+1) --just to speed up natural regen a bit
        end
        meta:set_int("breath", breath) --saves it in case the player quits and returns
        obj:hud_change(drown_huds[name], "text", "sub_core_fade_hud.png^[opacity:"..math.min(math.floor(meta:get_float("drown_progress")*64), 255))

        --update depth
        obj:hud_change(depth_huds[name], "text", (eye_pos.y > 0 and "0m") or tostring(math.round(-eye_pos.y)).."m")
    end
end)