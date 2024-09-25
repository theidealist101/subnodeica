sub_bases = {}

local path = minetest.get_modpath("sub_bases").."/"
local worldpath = minetest.get_worldpath().."/"

--Register information pertaining to an exterior or interior piece
sub_bases.registered_pieces = {}

function sub_bases.register_piece(name, defs)
    defs.size = defs.size or vector.zero()
    defs.schems = defs.schems or {}
    defs.schems.fixed = defs.schems.fixed
    defs.sides = defs.sides or {}
    sub_bases.registered_pieces[name] = defs
    sub_crafts.register_craft({
        type = "builder",
        category = defs.category,
        subcategory = defs.subcategory,
        output = name,
        output_icon = defs.icon,
        recipe = defs.recipe
    })
end

sub_bases.registered_side_pieces = {}

function sub_bases.register_side_piece(name, defs)
    defs.size = defs.size or vector.zero()
    defs.suffix = defs.suffix
    defs.types = defs.types or {}
    sub_bases.registered_side_pieces[name] = defs
    sub_crafts.register_craft({
        type = "builder",
        category = defs.category,
        subcategory = defs.subcategory,
        output = name,
        output_icon = defs.icon,
        recipe = defs.recipe
    })
end

--Utility functions
function sub_bases.get_piece_size(defs, rot)
    return vector.apply(vector.rotate(vector.floor(0.5*defs.size), rot), math.abs)
end

minetest.mkdir(worldpath.."schems")

local function get_replace_path(pos)
    return worldpath.."schems/piece_replace_"..string.format("%.f", minetest.hash_node_position(pos))..".mts"
end

local zero = vector.zero()

--Get which schems from piece definition should be used
local function get_piece_schems(defs, sides)
    local out = {}
    if defs.schems.fixed then
        table.insert(out, defs.schems.fixed)
    end
    for i, side in ipairs(defs.sides) do
        table.insert(out, {name=side.type..(sides[i] and "_"..sides[i] or "")..".mts", pos=side.pos, rot=side.rot})
    end
    return out
end

local box_text = "[fill:16x16:0,0:#80c0ff80"

--Invisible entity containing information about piece at given position
minetest.register_entity("sub_bases:piece", {
    initial_properties = {
        visual = "cube",
        textures = {box_text, box_text, box_text, box_text, box_text, box_text},
        use_texture_alpha = true,
        glow = 15,
        physical = false,
        pointable = false,
        is_visible = false
    },
    on_activate = function (self, staticdata)
        if not staticdata or staticdata == "" then return end
        self.piece = staticdata
        self.piece_defs = sub_bases.registered_pieces[staticdata]
        self.object:set_properties({visual_size=self.piece_defs.size+vector.new(0.1, 0.1, 0.1)})
    end,
    get_staticdata = function (self)
        return self.piece --position and rotation match that of the entity
    end,
    _set_piece = function (self, piece)
        if piece then
            self.piece = piece
            self.piece_defs = sub_bases.registered_pieces[piece]
            self.object:set_properties({visual_size=self.piece_defs.size+vector.new(0.1, 0.1, 0.1)})
        else piece = self.piece end
        local pos = self.object:get_pos()
        local rot = self.object:get_rotation()
        local rotation = math.round(math.deg(rot.y)/90)*90
        local size = sub_bases.get_piece_size(self.piece_defs, rot)
        minetest.create_schematic(pos-size, pos+size, {}, get_replace_path(pos))
        for _, schem in ipairs(get_piece_schems(self.piece_defs, {})) do
            minetest.place_schematic(pos+vector.rotate(schem.pos or zero, rot), path.."schems/"..schem.name, tostring((-rotation+(tonumber(schem.rot) or 0))%360), {}, true, "place_center_x, place_center_y, place_center_z")
        end
    end,
    on_deactivate = function (self, removal)
        if removal then
            local pos = self.object:get_pos()
            local replace = get_replace_path(pos)
            minetest.place_schematic(pos, replace, "0", {}, true, "place_center_x, place_center_y, place_center_z")
            minetest.rmdir(replace)
        end
    end
})

--Place a piece at a given position and rotation
function sub_bases.place_piece(pos, rot, piece)
    local out = minetest.add_entity(pos, "sub_bases:piece")
    local entity = out:get_luaentity()
    out:set_rotation(rot)
    entity:_set_piece(piece)
    return out
end

--Get piece at position
function sub_bases.get_piece_at(pos)
    if not pos then return end
    for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 32)) do
        local entity = obj:get_luaentity()
        if entity and entity.piece then
            local obj_pos = obj:get_pos()
            local size = sub_bases.get_piece_size(entity.piece_defs, obj:get_rotation())
            if VoxelArea(obj_pos-size, obj_pos+size):contains(pos.x, pos.y, pos.z) then
                return obj
            end
        end
    end
end

dofile(path.."builder.lua")
dofile(path.."nodes.lua")
dofile(path.."pieces.lua")