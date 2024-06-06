sub_inv = {}

--Make sure inventory is the right size
minetest.register_on_joinplayer(function(player)
    player:get_inventory():set_size("main", 48)
    player:hud_set_hotbar_itemcount(6)
end)

--Custom inventory layout
function sub_inv.make_formspec(player, context, content, show_inv, size)
    return table.concat({
        "formspec_version[8]",
        size or "size[15.25,10.25]",
        sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx),
        show_inv and "list[current_player;main;0.25,0.25;6,8;]" or "",
        content
    }, "")
end

--Homepage: inventory view
sfinv.register_page("sub_inv:inventory", {
    title = "Inventory",
    get = function (self, player, context)
        return sub_inv.make_formspec(player, context, "", true)
        --TODO: add equips, items taking up several slots, automatic item sorting etc. to emulate Subnautica inventory
    end
})

--Databank: holds scan data, information etc.
function sub_inv.add_databank_entry(player, name, text, category, subcategory)
    local meta = player:get_meta()
    local data_str = meta:get_string("databank")
    local databank = (data_str == "" and {}) or minetest.deserialize(data_str)
    local t = databank
    if category then
        t[category] = t[category] or {}
        t = t[category]
        if subcategory then
            t[subcategory] = t[subcategory] or {}
            t = t[subcategory]
        end
    end
    t[name] = text
    meta:set_string("databank", minetest.serialize(databank))
end

local function get_databank_formspec(player, context)
    local category, subcategory, entry = context.databank_nav_category, context.databank_nav_subcategory, context.databank_nav_entry
    local meta = player:get_meta()
    local data_str = meta:get_string("databank")
    local databank = (data_str == "" and {}) or minetest.deserialize(data_str)
    local out = {
        "style_type[label;font_size=*2]",
        "scroll_container[0.25,0.25;4.5,9.75;databank_nav;vertical;]"
    }
    local y = 0
    for cname, c in pairs(databank) do
        table.insert(out, table.concat({"button[0,", y, ";4,0.5;", cname, ";", cname, "]"}))
        y = y+0.5
        if cname == category and type(c) == "table" then
            for sname, s in pairs(c) do
                local sname2 = cname.."|"..sname
                table.insert(out, table.concat({"button[0.25,", y, ";4,0.5;", sname2, ";", sname, "]"}))
                y = y+0.5
                if sname == subcategory and type(s) == "table" then
                    for ename, e in pairs(s) do
                        local ename2 = sname.."|"..ename
                        table.insert(out, table.concat({"button[0.5,", y, ";4,0.5;", ename2, ";", ename, "]"}))
                        y = y+0.5
                    end
                end
            end
        end
    end
    table.insert(out, "scroll_container_end[]")
    if y > 9.5 then
        table.insert(out, table.concat({"scrollbaroptions[max=", y*10, ";smallstep=5;largestep=20]"}, ""))
        table.insert(out, "scrollbar[5,0.25;0.5,9.75;vertical;databank_nav;]")
    end
    local title, text
    if category and databank[category] then
        if type(databank[category]) == "string" then
            title = category
            text = databank[category]
        elseif subcategory and databank[category][subcategory] then
            if type(databank[category][subcategory]) == "string" then
                title = subcategory
                text = databank[category][subcategory]
            elseif entry and type(databank[category][subcategory][entry]) == "string" then
                title = entry
                text = databank[category][subcategory][entry]
            end
        end
    end
    if title then
        table.insert(out, "label[6,0.75;"..title.."]")
        table.insert(out, "textarea[6,1.5;9,8.5;;"..text..";]")
    end
    return table.concat(out, "")
end

local function databank_receive_fields(self, player, context, fields)
    for name, value in pairs(fields) do
        if value and name ~= "databank_nav" then
            if name == "quit" then return end
            local category, subcategory, entry = unpack(string.split(name, "|"))
            context.databank_nav_category = category
            context.databank_nav_subcategory = subcategory
            context.databank_nav_entry = entry
            sfinv.set_page(player, "sub_inv:databank")
            return
        end
    end
end

sfinv.register_page("sub_inv:databank", {
    title = "Databank",
    get = function (self, player, context)
        return sub_inv.make_formspec(player, context, get_databank_formspec(player, context))
    end,
    on_player_receive_fields = databank_receive_fields
})

local survival_package = {
    ["Start Here"] = [[If you are reading this, you have survived an emergency evacuation of a capital-class ship equipped with Alterra technology. Congratulations - the hard part is over.

Your PDA has automatically rebooted in emergency mode. This operating system has one directive: to keep you alive on a hostile alien world. If that is not possible, it will alert salvage teams to the location of your remains.

It features:
- Full monitoring of vital signs for timely survival advice
- Blueprints for fabricating a range of essential survival equipment, tailored to your environment
- Onboard camera, microphone and OCR technology for short-range situational analysis - Cross-compatibility with all Alterra-compliant products

Your personal and work files have been encrypted, and may be retrieved at a later date by a licensed engineer.]],

    ["Survival Checklist"] = [[1. Administer first aid if required
2. Take inventory of available materials and supplies, and decide on rations
3. Survey the environment for threats and resources
4. Construct necessary survival equipment using the lifepod's inbuilt fabricator
5. Check lifepod for damage, and repair as necessary
6. Broadcast local distress signal using lifepod's short-range radio
7. Locate other survivors using line of sight or the radio
8. Find or construct a more permanent habitat
9. Maintain physical and psychological health until rescue

This information is meant as a general guide. In the first instance you should always follow the advice of your PDA, which has taken your particular circumstances into account.]],

    ["WARNING: Corrupted"] = [[Damage to your PDA's hard drive has corrupted approximately 80% of stored survival blueprints. Blueprints may be reacquired by scanning salvaged technology using the handheld scanner, or by redownloading plans from a ship-board databox. In the circumstances, these assets will most likely be found amongst wreckage from the Aurora.]]
}

minetest.register_on_newplayer(function(player)
    for name, text in pairs(survival_package) do
        sub_inv.add_databank_entry(player, name, text, "Survival Package")
    end
end)

--Get rid of default page
sfinv.override_page("sfinv:crafting", {is_in_nav=function() end})

function sfinv.get_homepage_name(player)
    return "sub_inv:inventory"
end