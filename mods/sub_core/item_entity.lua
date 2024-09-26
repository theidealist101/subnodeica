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
    local itemname = string.split(self.itemstring, " ")[1]
    if itemname then self._hovertext = "Pick up "..minetest.registered_items[itemname].description.." (RMB)" end
end

minetest.register_entity(":__builtin:item", item_defs)

--Corpse, special entity which replaces fauna when they die
--note to self: thermoblades should deal corpse_eat damage as well
minetest.register_entity("sub_core:corpse", {
    initial_properties = {
        physical = false,
        is_visible = false
    },
    entity = "",
    set_entity = function (self, entity)
        entity = entity or self.entity
        local defs = minetest.registered_entities[entity]
        if not defs then return end
        local props = table.copy(defs.initial_properties)
        props.physical = true
        props.is_visible = true
        props.hp_max = defs.max_hp or props.hp_max
        props.static_save = not defs.corpse_despawn
        self.object:set_properties(props)
        self.entity = entity
    end,
    on_activate = function (self, staticdata)
        if staticdata and staticdata ~= "" then self:set_entity(staticdata) end
        self.object:set_acceleration(vector.new(0, ITEM_GRAVITY, 0))
        self.object:set_armor_groups({corpse_eat=100})
    end,
    on_step = function (self)
        self.object:set_acceleration(vector.new(0, ITEM_GRAVITY, 0))
    end,
    get_staticdata = function (self)
        return self.entity
    end
})

--Turn entity into corpse, return corpse if successful otherwise nil
function sub_core.become_corpse(self)
    local corpse = minetest.add_entity(self.object:get_pos(), "sub_core:corpse", self.name)
    if not corpse then return end
    corpse:set_rotation(vector.new(0, self.object:get_rotation().y, (math.random()+0.5)*math.pi))
    self.object:remove()
    return corpse
end