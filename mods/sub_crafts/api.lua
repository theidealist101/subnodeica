--All recipe types will be as follows:
-- "fabricator" (fabricator)
--- "resources"
---- "basic"
---- "advanced"
---- "electronics"
--- "sustenance"
---- "water"
---- "cooked"
---- "cured"
--- "personal"
---- "equipment"
---- "tools"
--- "deployables"
-- "workbench" (modification station)
-- "builder" (habitat builder, may use different formspec)
--- "extpiece"
--- "extmodule"
--- "intpiece"
--- "intmodule"
--- "misc"
-- "constructor" (mobile vehicle bay)
--- "vehicles"
--- "neptune"
-- "scanner" (scanner room fabricator)
-- "moonpool" (vehicle upgrade console)
--- "common"
--- "seamoth"
--- "prawn"
--- "torpedo"
-- "cyclops" (cyclops upgrade fabricator)
-- "launch" (neptune launch terminal)

--Convert colon into double hyphen (because colons in names in style[] elements weren't working)
local function escape_colon(str)
    return table.concat(string.split(str, ":"), "--")
end

--Register crafting recipe of any sort
sub_crafts.registered_crafts = {}

function sub_crafts.register_craft(defs)
    defs.type = defs.type or "fabricator"
    defs.category = defs.category --can be nil
    defs.subcategory = defs.subcategory --ditto
    defs.output = defs.output or {}
    defs.recipe = defs.recipe or {}
    table.insert(sub_crafts.registered_crafts, defs)
    return #sub_crafts.registered_crafts
end

--Get whether player has the necessary items and blueprints to do a recipe
function sub_crafts.can_do_recipe(inv, recipe)
    for i, item in ipairs(recipe) do
        if not inv:contains_item("main", ItemStack(item)) then return false end
    end
    --TODO: add blueprints
    return true
end

--Get whether something is a valid recipe
function sub_crafts.get_recipe(rtype, item, category, subcategory)
    for i, defs in ipairs(sub_crafts.registered_crafts) do
        if defs.type == rtype and escape_colon(defs.output[1]) == item
        and defs.category == category and defs.subcategory == subcategory then return defs end
    end
end

--Show formspec given recipe type, category and subcategory
local PADDING = 0.25

function sub_crafts.get_formspec(player, rtype, category, subcategory)
    local inv = player:get_inventory()

    --get all applicable recipes and subgroups
    local level1, level2, level3 = {}, {}, {}
    for i, defs in ipairs(sub_crafts.registered_crafts) do
        local doable = sub_crafts.can_do_recipe(inv, defs.recipe)
        if defs.type == rtype then
            if defs.category == nil then
                level1[defs] = doable
            else
                level1[defs.category] = level1[defs.category] or doable
                if defs.category == category then
                    if defs.subcategory == nil then
                        level2[defs] = doable
                    else
                        level2[defs.subcategory] = level2[defs.subcategory] or doable
                        if defs.subcategory == subcategory then
                            level3[defs] = doable
                        end
                    end
                end
            end
        end
    end

    --build the formspec
    local out = {
        "bgcolor[black;neither]"
    }
    local doable_elems = {}
    local x_offset = 20
    local y_offset = 20
    local height = 0
    local offset = 0
    for defs, doable in pairs(level1) do
        local name
        if type(defs) == "string" then
            if defs == category then offset = height end
            name = defs
            table.insert(out, table.concat({"image_button[", x_offset, ",", y_offset+height, ";1,1;", name, ".png;", name, ";]tooltip[", name, ";", string.upper(string.sub(name, 1, 1)), string.sub(name, 2), "]"}))
        else
            name = defs.output[1]
            table.insert(out, table.concat({"item_image_button[", x_offset, ",", y_offset+height, ";1,1;", name, ";", name, ";]"}))
        end
        if doable then table.insert(doable_elems, name) end
        height = height+1+PADDING
    end
    local max_height = height
    height = offset
    offset = 0
    for defs, doable in pairs(level2) do
        local name
        if type(defs) == "string" then
            if defs == subcategory then offset = height end
            name = category.."|"..defs
            table.insert(out, table.concat({"image_button[", x_offset+1+PADDING, ",", y_offset+height, ";1,1;", defs, ".png;", name, ";]tooltip[", name, ";", string.upper(string.sub(defs, 1, 1)), string.sub(defs, 2), "]"}))
        else
            name = category.."|"..defs.output[1]
            table.insert(out, table.concat({"item_image_button[", x_offset+1+PADDING, ",", y_offset+height, ";1,1;", defs.output[1], ";", name, ";]"}))
        end
        if doable then table.insert(doable_elems, name) end
        height = height+1+PADDING
    end
    max_height = math.max(height, max_height)
    height = offset
    offset = 0
    local x = 2+2*PADDING
    for defs, doable in pairs(level3) do
        local name = category.."|"..subcategory.."|"..escape_colon(defs.output[1])
        table.insert(out, table.concat({"item_image_button[", x_offset+x, ",", y_offset+height, ";1,1;", defs.output[1], ";", name, ";]"}))
        if doable then table.insert(doable_elems, name) end
        x = x+1+PADDING
        if x > 4 then
            x = 2+2*PADDING
            height = height+1+PADDING
        end
    end
    max_height = math.max(height+1+PADDING, max_height)
    return "formspec_version[4]size["..(2*x_offset+1)..","..(2*y_offset+2+PADDING)..",true]".."style["..table.concat(doable_elems, ",")..";bgcolor=#00ffff]"..table.concat(out)
end