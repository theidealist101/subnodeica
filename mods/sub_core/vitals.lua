--Defaults for stats (how many seconds it takes each one to run out)
sub_core.max_hunger = 3000
sub_core.max_thirst = 2000
sub_core.max_breath = 45

local enable_damage = minetest.settings:get_bool("enable_damage")

--HUDs for each player
local hunger_huds = {}
local hunger_huds2 = {}
local thirst_huds = {}
local drown_huds = {}
local depth_huds = {}
local hovertext_huds = {}

local hunger_hud_defs = {
    type = "statbar",
    position = {x=0.5, y=1},
    size = {x=24, y=24},
    alignment = {x=-1, y=-1},
    offset = {x=-265, y=-115},
    text = "stamina_hud_fg.png",
    number = 20
}

local hunger_hud_defs2 = {
    type = "statbar",
    position = {x=0.5, y=1},
    size = {x=24, y=24},
    alignment = {x=-1, y=-1},
    offset = {x=-265, y=-135},
    text = "stamina_hud_fg.png",
    number = 0
}

local thirst_hud_defs = {
    type = "statbar",
    position = {x=0.5, y=1},
    size = {x=24, y=24},
    alignment = {x=-1, y=-1},
    offset = {x=24, y=-115},
    text = "sub_core_thirst_hud.png",
    number = 20
}

local drown_hud_defs = {
    type = "image",
    text = "sub_core_fade_hud.png^[opacity:0",
    position = {x=0.5, y=0.5},
    z_index = 1000,
    scale = {x=-100, y=-100}
}

local depth_hud_defs = {
    type = "text",
    position = {x=0.5, y=0},
    offset = {x=0, y=32},
    scale = {x=100, y=100},
    size = {x=3, y=3},
    style = 4,
    number = 0x9ffeff,
    text = "0m"
}

local hovertext_hud_defs = {
    type = "text",
    position = {x=0.5, y=0.5},
    offset = {x=0, y=32},
    scale = {x=100, y=100},
    size = {x=1, y=1},
    style = 0,
    number = 0xffffff,
    text = ""
}

--Functions for adding to stats
function sub_core.do_item_eat(food, water, oxygen, itemstack, user)
    local meta = user:get_meta()
    local hunger = meta:get_int("hunger")
    local thirst = meta:get_int("thirst")
    local breath = user:get_breath()
    local used = false
    if food ~= 0 and (food < 0 or hunger < sub_core.max_hunger) then
        meta:set_int("hunger", hunger+food*sub_core.max_hunger*0.01)
        used = true
    end
    if water ~= 0 and (water < 0 or thirst < sub_core.max_thirst) then
        meta:set_int("thirst", math.min(thirst+water*sub_core.max_thirst*0.01, sub_core.max_thirst))
        used = true
    end
    if oxygen ~= 0 and (oxygen < 0 or breath < user:get_properties().breath_max) then
        user:set_breath(breath+oxygen)
        used = true
    end
    if used then itemstack:take_item() end
    return itemstack
end

function sub_core.item_eat(food, water, oxygen)
    oxygen = oxygen or 0
    return function (itemstack, user)
        return sub_core.do_item_eat(food, water, oxygen, itemstack, user)
    end
end

--Player monoids for swim speed and O2 capacity
sub_core.swim_monoid = player_monoids.make_monoid({
    identity = 1,
    combine = function(a, b) return a*b end,
    fold = function (t)
        local out = 1
        for _, v in pairs(t) do out = out*v end
        return out
    end
})

sub_core.o2_monoid = player_monoids.make_monoid({
    identity = 0,
    combine = function(a, b) return a+b end,
    fold = function (t)
        local out = 0
        for _, v in pairs(t) do out = out+v end
        return out
    end,
    apply = function (val, player)
        player:set_properties({breath_max=sub_core.max_breath+val})
    end
})

--Give player correct armor groups and stuff
minetest.register_on_joinplayer(function(player)
    player:set_armor_groups({
        normal = 100,
        gas = 100,
        fire = 100
    })
    local meta = player:get_meta()
    local name = player:get_player_name()
    if enable_damage then
        if not meta:contains("hunger") then meta:set_float("hunger", sub_core.max_hunger) end
        if not meta:contains("thirst") then meta:set_float("thirst", sub_core.max_thirst) end
        hunger_huds[name] = player:hud_add(hunger_hud_defs)
        hunger_huds2[name] = player:hud_add(hunger_hud_defs2)
        thirst_huds[name] = player:hud_add(thirst_hud_defs)
    end
    depth_huds[name] = player:hud_add(depth_hud_defs)
    hovertext_huds[name] = player:hud_add(hovertext_hud_defs)
    if drown_huds[name] then --in case the player died of drowning
        player:hud_remove(drown_huds[name])
    end
    if meta:get_float("drown_progress") > 4 then meta:set_float("drown_progress", 4) end
    drown_huds[name] = player:hud_add(drown_hud_defs)
    local props = player:get_properties()
    props.breath_max = sub_core.max_breath+sub_core.o2_monoid:value(player)
    player:set_properties(props)
    player:set_eye_offset(vector.zero())
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
        if enable_damage then
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
        end

        --update breath
        local eye_pos = obj:get_pos()+vector.new(0, 1.625, 0)
        local inv = obj:get_inventory()
        local node_def = minetest.registered_nodes[minetest.get_node(vector.round(eye_pos)).name]
        local breath = obj:get_breath()
        local drown_progress = meta:get_float("drown_progress")
        local parent = obj:get_attach()
        if obj:get_hp() <= 0 then
            drown_progress = drown_progress+dtime
        elseif parent and parent:get_luaentity().breathable then
            breath = breath+3 --has to counteract natural depletion
        elseif node_def and node_def.drowning and node_def.drowning > 0 then
            if breath <= 0 then
                drown_progress = drown_progress+dtime
                if drown_progress >= 8 then
                    obj:set_hp(0, {type="drown", death=true})
                end
            end
        else
            breath = breath+1 --just to speed up natural regen a bit
        end
        if breath > 0 then
            drown_progress = drown_progress-2*dtime
        end
        drown_progress = math.min(math.max(drown_progress, 0), 8)
        meta:set_float("drown_progress", drown_progress)
        obj:set_breath(breath)
        meta:set_int("breath", breath) --saves it in case the player quits and returns
        if not inv:is_empty("tank") then
            local item = inv:get_stack("tank", 1)
            item:set_wear(math.min(math.max(math.floor(65535-65535*(breath-sub_core.max_breath)/sub_core.o2_monoid:value(obj)), 0), 65535))
            inv:set_stack("tank", 1, item)
        end
        obj:hud_change(drown_huds[name], "text", "sub_core_fade_hud.png^[opacity:"..math.min(math.floor(drown_progress*64), 255))

        --update depth
        obj:hud_change(depth_huds[name], "text", (eye_pos.y > 0 and "0m") or tostring(math.round(-eye_pos.y)).."m")

        --update swim speed
        if minetest.registered_nodes[minetest.get_node(vector.round(obj:get_pos())).name].liquid_move_physics then
            obj:set_physics_override({speed=sub_core.swim_monoid:value(obj)})
        else
            obj:set_physics_override({speed=1})
        end

        --update hovertext
        local hovertext
        local itemstack = obj:get_wielded_item()
        local raycast = minetest.raycast(eye_pos, eye_pos+4*obj:get_look_dir())
        raycast:next() --discard player
        local pointed = raycast:next() or {type="nothing"}
        if not itemstack:is_empty() and itemstack:is_known() then
            hovertext = itemstack:get_meta():get("hovertext") or minetest.registered_items[itemstack:get_name()]._hovertext
        end
        if not hovertext then
            if pointed.type == "node" then
                hovertext = minetest.get_meta(pointed.under):get("hovertext") or minetest.registered_nodes[minetest.get_node(pointed.under).name]._hovertext
            elseif pointed.type == "object" then
                hovertext = (pointed.ref:get_luaentity() or {})._hovertext
            end
        end
        if type(hovertext) == "function" then hovertext = hovertext(itemstack, obj, pointed) end
        obj:hud_change(hovertext_huds[name], "text", hovertext or "")
    end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if reason.type == "drown" and not reason.death then return 0, true end
    return hp_change
end, true)

minetest.register_on_respawnplayer(function(player)
    player:get_meta():set_float("drown_progress", 8)
end)