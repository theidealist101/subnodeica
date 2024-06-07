--Homepage: inventory view
sfinv.register_page("sub_inv:inventory", {
    title = "Inventory",
    get = function (self, player, context)
        return sub_inv.make_formspec(player, context, "", true)
        --TODO: add equips, items taking up several slots, automatic item sorting etc. to emulate Subnautica inventory
    end
})

--Get rid of default page
sfinv.override_page("sfinv:crafting", {is_in_nav=function() end})

function sfinv.get_homepage_name(player)
    return "sub_inv:inventory"
end