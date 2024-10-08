local box_text = "[fill:16x16:0,0:#80c0ffc0"
local box_text_red = "[fill:16x16:0,0:#ff8080c0"
local box_text_blue = "[fill:16x16:0,0:#8080ffc0"

--Entity showing bounding box of piece to be placed
minetest.register_entity("sub_bases:box", {
    initial_properties = {
        visual = "cube",
        textures = {box_text, box_text, box_text, box_text, box_text, box_text},
        use_texture_alpha = true,
        glow = 15,
        physical = false,
        pointable = false,
        static_save = false
    },
    on_activate = function (self, staticdata)
        if not staticdata or staticdata == "" then self.object:remove() end
        self.piece = staticdata
        self.piece_defs = sub_bases.registered_pieces[self.piece]
        self.object:set_properties({visual_size=self.piece_defs.size+vector.new(0.1, 0.1, 0.1)})
    end
})

--Various utilities involving boxes
local box_objs = {}
local selected_pieces = {}
local eye_offset = vector.new(0, 1.625, 0)
local rotate_amount = vector.new(0, math.pi/2, 0)

local function get_box_pos(player)
    return vector.round(player:get_pos()+eye_offset+8*player:get_look_dir())
end

local function check_box_collisions(obj)
    local size = sub_bases.get_piece_size(obj:get_luaentity().piece_defs, obj:get_rotation())
    local pos = obj:get_pos()
    for x = -size.x, size.x do
        for y = -size.y, size.y do
            for z = -size.z, size.z do
                if not minetest.registered_nodes[minetest.get_node(pos+vector.new(x, y, z)).name].buildable_to then return true end
            end
        end
    end
    return false
end

local aux1 = {}

--Update position of box entity for each player
minetest.register_globalstep(function ()
    for _, player in ipairs(minetest.get_connected_players()) do
        local playername = player:get_player_name()
        local pos = player:get_pos()+eye_offset
        local obj = box_objs[playername]
        local building = player:get_wielded_item():get_name() == "sub_bases:builder"
        if obj and building then --currently placing box
            obj:set_pos(get_box_pos(player))
            if player:get_player_control().aux1 then
                if not aux1[playername] then
                    obj:set_rotation(obj:get_rotation()+rotate_amount)
                end
                aux1[playername] = true
            else
                aux1[playername] = false
            end
            local texture = check_box_collisions(obj) and box_text_red or box_text
            obj:set_properties({textures={texture, texture, texture, texture, texture, texture}})
        elseif obj then --no longer placing box
            obj:remove()
            box_objs[playername] = nil
        elseif building then --possibly pointing at box
            local raycast = minetest.raycast(pos, pos+8*player:get_look_dir())
            raycast:next() --discard player
            local piece = sub_bases.get_piece_at(minetest.get_pointed_thing_position(raycast:next() or {type="nothing"}))
            local old_piece = selected_pieces[player]
            if piece ~= old_piece then
                selected_pieces[player] = piece
                if old_piece then old_piece:set_properties({is_visible=false}) end
                if piece then piece:set_properties({is_visible=true}) end
            end
        elseif selected_pieces[player] then --no longer pointing at box
            selected_pieces[player]:set_properties({is_visible=false})
            selected_pieces[player] = nil
        end
    end
end)

--Habitat builder, places base pieces and modules
local function place_box(_, user)
    local playername = user:get_player_name()
    if box_objs[playername] then
        box_objs[playername]:remove()
        box_objs[playername] = nil
    else
        local pos = user:get_pos()+eye_offset
        local raycast = minetest.raycast(pos, pos+8*user:get_look_dir())
        raycast:next() --discard player
        local piece = sub_bases.get_piece_at(minetest.get_pointed_thing_position(raycast:next() or {type="nothing"}))
        if piece then
            piece:remove()
        else
            box_objs[playername] = minetest.add_entity(get_box_pos(user), "sub_bases:box", "sub_bases:i_compartment")
        end
    end
end

local function confirm_box(_, user)
    local playername = user:get_player_name()
    local obj = box_objs[playername]
    if obj and not check_box_collisions(obj) then
        --obj:set_properties({textures={box_text_blue, box_text_blue, box_text_blue, box_text_blue, box_text_blue, box_text_blue}})
        box_objs[playername] = nil
        sub_bases.place_piece(obj:get_pos(), obj:get_rotation(), obj:get_luaentity().piece)
        obj:remove()
    end
end

minetest.register_tool("sub_bases:builder", {
    description = "Habitat Builder",
    inventory_image = "sub_bases_builder.png",
    stack_max = 1,
    on_place = place_box,
    on_secondary_use = place_box,
    on_use = confirm_box
})