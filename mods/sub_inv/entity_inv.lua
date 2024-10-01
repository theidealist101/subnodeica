local storage = minetest.get_mod_storage()

--Add entity inventory
function sub_inv.add_entity_inv(entity, size, inv_save)
    if type(entity) == "userdata" then entity = entity:get_luaentity() end
    local id = storage:get_int("next_id")
    storage:set_int("next_id", id+1)
    entity._inv_id = id
    local out = minetest.create_detached_inventory("sub_inv:entity_inv_"..id)
    out:set_size("main", size)
    if inv_save and inv_save ~= "" then
        sub_inv.load_entity_inv(out, inv_save)
    end
    return out
end

--Remove entity inventory
function sub_inv.del_entity_inv(entity)
    if type(entity) == "userdata" then entity = entity:get_luaentity() end
    return minetest.remove_detached_inventory("sub_inv:entity_inv_"..entity._inv_id)
end

--Get entity inventory reference
function sub_inv.get_entity_inv(entity)
    if type(entity) == "userdata" then entity = entity:get_luaentity() end
    return minetest.get_inventory({type="detached", name="sub_inv:entity_inv_"..entity._inv_id})
end

--Serialize entity inventory for storage
function sub_inv.save_entity_inv(entity)
    if type(entity) == "userdata" then entity = entity:get_luaentity() end
    local inv = sub_inv.get_entity_inv(entity)
    local out = {}
    for _, item in ipairs(inv:get_list("main")) do table.insert(out, item:to_string()) end
    return minetest.serialize(out)
end

--Deserialize entity inventory from storage
function sub_inv.load_entity_inv(inv, save)
    for i, item in ipairs(minetest.deserialize(save)) do inv:set_stack("main", i, ItemStack(item)) end
end

--Show entity inventory formspec to the player
function sub_inv.show_entity_inv(entity, player)
    if type(entity) == "userdata" then entity = entity:get_luaentity() end
    local size = sub_inv.get_entity_inv(entity):get_size("main")
    local width = math.min(math.floor(math.sqrt(size)), 6)
    local height = math.min(math.ceil(size/width), 8)
    return minetest.show_formspec(player:get_player_name(), "sub_inv:entity_inv_formspec", "formspec_version[8]size[15.25,10.25]list[current_player;main;0.25,0.25;6,8;]list[detached:sub_inv:entity_inv_"..entity._inv_id..";main;"..(11.5-0.625*width)..","..(5.25-0.625*height)..";"..width..","..height..";]")
end