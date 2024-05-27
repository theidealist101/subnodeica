--A couple tools for making creative building easier
minetest.register_craftitem("sub_core:magic_stick", {
    description = "Magic Stick",
    inventory_image = "default_stick.png",
    on_place = function (itemstack, user, pointed)
        if pointed.type == "node" then
            minetest.remove_node(pointed.under)
        end
    end
})