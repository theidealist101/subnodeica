sub_core = {}

local path = minetest.get_modpath("sub_core").."/"
dofile(path.."creative.lua")
dofile(path.."water.lua")
dofile(path.."vitals.lua")
dofile(path.."mapgen.lua")
dofile(path.."item_entity.lua")
dofile(path.."nodes.lua")
dofile(path.."void.lua")
dofile(path.."shallows.lua")
dofile(path.."forest.lua")
dofile(path.."grassland.lua")
--dofile(path.."debug_biome.lua")