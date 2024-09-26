sub_core = {}

--Ordered map object (will probably be moved elsewhere later)
dict = {}

dict.metatable = {
    __index = function (self, key)
        for _, v in ipairs(self._i) do
            if v[1] == key then
                return v[2]
            end
        end
    end,
    __newindex = function (self, key, val)
        for _, v in ipairs(self._i) do
            if v[1] == key then
                v[2] = val
                return
            end
        end
        table.insert(self._i, {key, val})
    end,
    __len = function (self)
        return #self._i
    end
}

function dict.new()
    return setmetatable({_i = {}}, dict.metatable)
end

function dict.pairs(t)
    local i, entry
    local function iter(d)
        i, entry = next(d, i)
        if entry then return entry[1], entry[2] end
    end
    return iter, t._i
end

setmetatable(dict, {__call = dict.new})

local path = minetest.get_modpath("sub_core").."/"
dofile(path.."creative.lua")
dofile(path.."mapgen.lua")
dofile(path.."water.lua")
dofile(path.."vitals.lua")
dofile(path.."item_entity.lua")
dofile(path.."sounds.lua")
dofile(path.."nodes.lua")
dofile(path.."void.lua")
dofile(path.."shallows.lua")
dofile(path.."forest.lua")
dofile(path.."grassland.lua")
--dofile(path.."debug_biome.lua")
minetest.register_mapgen_script(path.."mapgen_env.lua")