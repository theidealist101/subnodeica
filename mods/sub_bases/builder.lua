--Invisible entity containing information about piece at given position
minetest.register_entity("sub_bases:piece", {
    initial_properties = {
        visual = "sprite",
        textures = {"blank.png"},
        physical = false,
        pointable = false
    },
    on_activate = function (self, staticdata)
        if not staticdata or staticdata == "" then self.object:remove() end
        self.piece, self.parent = unpack(minetest.deserialize(staticdata))
        self.piece_defs = sub_bases.registered_pieces[self.piece]
    end,
    get_staticdata = function (self)
        return minetest.serialize({self.piece, self.parent}) --position and rotation match that of the entity
    end
})

local box_text = "sub_bases_titanium_block.png^[opacity:192"

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
        self.object:set_properties({visual_size=self.piece_defs.size})
    end
})

--Habitat builder, places base pieces and modules
minetest.register_tool("sub_bases:builder", {
    description = "Habitat Builder",
    inventory_image = "sub_bases_builder.png",
    stack_max = 1,
    on_place = function (itemstack, user, pointed)
        minetest.add_entity(minetest.get_pointed_thing_position(pointed, true), "sub_bases:box", "sub_bases:i_compartment")
    end
})