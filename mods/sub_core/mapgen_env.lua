---@diagnostic disable: duplicate-set-field
sub_core = {}

function minetest.register_abm(...) end
function minetest.register_globalstep(...) end
function minetest.register_node(...) end
function sub_core.drop_if_slash(...) end
function minetest.register_craftitem(...) end

local path = minetest.get_modpath("sub_core").."/"
dofile(path.."water.lua")
dofile(path.."mapgen.lua")
dofile(path.."void.lua")
dofile(path.."shallows.lua")
dofile(path.."forest.lua")
dofile(path.."grassland.lua")

minetest.register_on_generated(sub_core.on_generate)