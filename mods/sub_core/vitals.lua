--Give player correct armor groups
minetest.register_on_joinplayer(function(player)
    player:set_armor_groups({
        normal = 100,
        gas = 100,
        fire = 100
    })
end)