Mapgen
======

Subnodeica uses the `singlenode` mapgen type; all other types are unavailable. On top of this it puts its own custom mapgen.

It does not use the mapgen async thread as Minetest 5.8 does not have that feature. This may cause significant lag whie exploring a world, manifested in chunks not appearing, entities rubber-banding, etc. - chunk load times in excess of 2000ms have been observed. It is recommended players only drive Seamoths in already explored areas until this is fixed.

All mapgen API functions are currently in the mod `sub_core`, mostly in the files `mapgen.lua` and `water.lua`. Biome definitions and decorations may be found each in their own respective files.

Biomes
------

The biome system used in Subnodeica is completely separate to the default one in Minetest; mods such as Find Biome currently do not work with it.

* `sub_core.registered_biomes`
    * Map of registered biome definitions, indexed by name.

* `sub_core.register_biome(name, defs)`
    * Registers a biome definition to be generated.
    * No return value.

A biome definition is a table with the following fields:

```lua
{
    name = "Shallows",
    --Display name of the biome - not currently used

    not_generated = false,
    --If true, biome is not generated in worlds but is still added to definitions

    node_top = "sub_core:sand",
    --Node forming a single layer on top of terrain

    node_stone = "sub_core:sandstone",
    --Node replacing stone underneath

    node_water = "sub_core:shallows_water",
    --Node used as water - see Water

    y_max = 31000,
    y_min = -31000,
    --Upper and lower limits for biome (biome spawning, NOT terrain)

    heat_point = 50,
    humid_point = 50,
    --Typical heat and humidity, decided similarly to Minetest's as noise compared to a Voronoi diagram
    
    dist_point = 0,
    --Typical horizontal Euclidean distance from the origin, also used in the Voronoi diagram

    noise = {noise defs},
    noise3d = {noise defs}
    --Noise functions combined to form terrain
    --Definitions are as used by minetest.get_perlin_map
    --Do not set the seed however, that is taken care of by the mapgen
}
```

Decorations
-----------

Again, the Subnodeica decoration system is separate to Minetest's. Single-block "decors" and multi-block "schems" use separate spawning mechanics and functions.

* `sub_core.registered_decors`
    * List of registered decor definitions.

* `sub_core.register_decor(defs)`
    * Registers a decor definition to be generated.
    * Returns its position in the list.

* `sub_core.registered_schems`
    * List of registered schematic definitions.

* `sub_core.register_schem(defs)`
    * Registers a schematic definition to be generated.
    * Returns its position in the list.

A decor definition is a table with the following fields:

```lua
{
    type = "top",
    --Where in the terrain to generate
    --Allowed types:
    -- "top" is placed on top of terrain, e.g. acid mushrooms
    -- "bottom" is placed under terrain overhangs, e.g. drooping stingers
    -- "surface" is placed in the top layer of the terrain, e.g. sand with lichen
    -- "underground" is placed within the terrain and may be exposed in cliffs or caves, e.g. sandstone with scales

    biome = "sub_core:shallows",
    --Name of biome to generate in
    --For a decor to spawn in multiple biomes, it must have multiple definitions

    decor = "sub_core:acidshroom1",
    --Name of node to place
    --If given a name that does not exist but is in the waterloggables table, it will place the correct waterlogged variant for each biome instead

    fill_ratio = 1,
    --Chance of spawning in any given location

    param2 = 0,
    max_param2 = 0,
    --Bounds for param2 value, intended for nodes to spawn with random rotations

    noise = {noise defs}
    --3D noise function giving chance of spawning (optional)
}
```

A schem definition is a table with the following fields:

```lua
{
    type = "top",
    fill_ratio = 1,
    biome = "sub_core:shallows",
    --Same as decor definition

    schem = minetest.get_modpath("sub_core").."/schems/coral_tube.mts",
    --File path of schematic to place

    radius = 5
    --Schematic will spawn at least this distance from the edges of the mapchunk
    --Important to prevent schematics being cut off at mapchunk edges
}
```

Water
-----

Minetest has no system for waterlogging nodes in any way - a grievous lack in my opinion. Therefore I have had to make a hacky solution to this, based on the fact that in Subnodeica flowing water is not generally a thing. For each type of water there are two nodes: a full nodebox with all faces but the top one transparent, for the surface; and an airlike node for the internal water. For each combination of water and waterloggable node, a separate node is defined.

There are many types of water, because my solution to Minetest's lack of biome coloring is to register a different type of water for every biome or group of sub-biomes. This does mean that biome boundaries appear very sharply defined on the surface, but after all the terrain isn't yet smoothed either. Biome fog is achieved with a globalstep checking what node the player's head is in, whereas the `post_effect_color` built into the nodes is handled by the client; so fog may lag behind the overlay.

* `sub_core.add_water_physics(node_def, water)`
    * Returns a copy of `node_def` with certain properties added from the definition of the node named `water` to simulate waterlogging (e.g. water physics, tint and fog, drowning).
    * Primarily used internally.

* `sub_core.get_waterlogged(node, water)`
    * Returns the name of the waterlogged node which would correspond to `node` and `water`. Does NOT check that any of these nodes exist!

* `sub_core.registered_waters`
    * Map of registered water definitions, indexed by node name.

* `sub_core.register_water(name, defs)`
    * Registers the water node called `name` and the water surface node called `name.."_surface"`, as well as corresponding waterlogged nodes for all waterloggables registered so far, using the water definition table `defs`.
    * No return value.

* `sub_core.registered_waterloggables`
    * Map of registered waterloggable node definitions, indexed by node name.

* `sub_core.register_waterloggable(name, defs)`
    * Registers waterlogged nodes corresponding to all water types registered so far. Does not currently register the base node: do not register another node with that name though, as waterlogged nodes are only checked by decor etc. if there is no node by the name.
    * `defs`: the node definition for the waterlogged nodes. Note that some properties are overridden by the waterlogging.

A water definition is a table with the following fields:

```lua
{
    description = "",
    color = {r=255, g=255, b=255},
    groups = {},
    --Same as node definition

    tint = {r=255, g=255, b=255, a=0},
    --Same as post_effect_color in node definition

    fog = {}
    --Fog definition table as accepted within player:set_sky()
}
```

Misc
----

* `sub_core.registered_spawners`
    * List of registered spawner definitions.

* `sub_core.register_spawner(name, exposed, hidden, defs)`
    * Registers a node which when generated will attempt to grow another node on itself, used for various decorations like limestone chunks.
    * `name`: the name of the node to be grown on itself, the spawner node itself is called `name.."_spawner"`. If given a name that does not exist but is in the waterloggables table, it will place the correct waterlogged variant for each biome instead.
    * `exposed`, `hidden`: the names of the nodes it will turn into after doing this if exposed or hidden within terrain.
    * `defs`: the node definition table for the spawner, recommended to be just a simple barebones node.
    * See examples in `nodes.lua`.

* `sub_core.registered_on_generates`
    * List of registered on generate callbacks.

* `sub_core.register_on_generate(function(minp, maxp, seed, voxelmanip))`
    * Called after the custom mapgen has been run.
    * `minp`, `maxp`: the two opposite corners of the mapchunk.
    * `seed`: the seed used to generate the mapchunk.
    * `voxelmanip`: the VoxelManip created in the mapgen, after terrain and decors but before spawners have been checked.

WIP
===