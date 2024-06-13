--Builtin item override to decrease gravity and some other stuff
local ITEM_GRAVITY = -1

local old_item_defs = minetest.registered_entities["__builtin:item"]
local item_defs = table.copy(old_item_defs)

--rightclick to pick up item
--also fixes issue with nodes which drop item when slashed
--(they would drop another item when you picked up the first)
item_defs.on_punch = nil
item_defs.on_rightclick = old_item_defs.on_punch

--override gravity value to simulate upthrust
item_defs.on_activate = function (self, staticdata, dtime)
    old_item_defs.on_activate(self, staticdata, dtime)
    self.object:set_velocity(vector.zero())
    self.object:set_acceleration({x=0, y=ITEM_GRAVITY, z=0})
end

item_defs.enable_physics = function (self)
    if not self.physical_state then
        self.physical_state = true
        self.object:set_properties({physical=true})
        self.object:set_velocity({x=0, y=0, z=0})
        self.object:set_acceleration({x=0, y=ITEM_GRAVITY, z=0})
    end
end

--get rid of some annoying stuff
item_defs.set_item = function (self, item)
    old_item_defs.set_item(self, item)
    self.object:set_properties({infotext="", automatic_rotate=0})
end


minetest.register_entity(":__builtin:item", item_defs)