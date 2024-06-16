Mapgen
======

Subnodeica uses the `singlenode` mapgen type; all other types are unavailable. On top of this it puts its own custom mapgen.

It does not use the mapgen async thread as Minetest 5.8 does not have that feature. This may cause significant lag whie exploring a world, manifested in chunks not appearing, entities rubber-banding, etc. - chunk load times in excess of 2000ms have been observed. It is recommended players only drive Seamoths in already explored areas until this is fixed.

All mapgen API functions are currently in the mod `sub_core`, mostly in the files `mapgen.lua` and `water.lua`. Biome definitions and decorations may be found each in their own respective files, mostly using nodes defined in `nodes.lua`.

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

Items and Crafting
==================

Crafting API functions are in `sub_crafts/api.lua` while item-related functions are in various places as necessary. Most crafting recipes are in `sub_crafts/crafts.lua`, as are the items they produce; basic harvested items are in `sub_core/nodes.lua` and more specialised items are defined in the mods they pertain to. Inventory API may be found in `sub_inv`.

Crafting
--------

Subnodeica uses its own crafting system, as the builtin one was inadequate for its needs. This API does probably need to be reworked significantly.

* `sub_crafts.registered_crafts`
    * List of registered crafting recipe definitions.

* `sub_crafts.register_craft(defs)`
    * Register a crafting recipe to be used by one of various crafting workstations.
    * No return value.

* `sub_crafts.get_recipe(type, item[, category[, subcategory]])`
    * Utility function for on_player_receive_fields functions handling crafting formspecs.
    * If there is a recipe in the given type, category and subcategory for the given item then it is returned, otherwise `nil`.
    * Note that `item` is expected with `"--"` used instead of `":"`, for internal formspec-related reasons.

* `sub_crafts.can_do_recipe(inventory, recipe)`
    * Returns whether there are materials for the given recipe in the inventory.
    * `inv` is an `InvRef` object, `recipe` is a crafting recipe definition.

* `sub_crafts.get_formspec(player, type[, category[, subcategory]])`
    * Creates a tree-like GUI showing crafting recipes for the player in the given type, category and subcategory, as used in e.g. fabricators.

A crafting recipe definition is a table with the following fields:

```lua
{
    type = "fabricator",
    --Type of recipe, defaults to "fabricator"
    --Currently used values: "fabricator", "constructor" (mobile vehicle bay)
    --See api.lua for a full list of types and categories intended to be added

    category = "resources",
    subcategory = "electronics",
    --Several layers of categorisation
    --May be displayed differently by different crafting formspecs

    output = {"sub_crafts:battery"},
    --List of output items as itemstrings
    --To output several of the same item you should add them as separate entries, so they don't come out in one stack

    output_icon = "seamoth_craft.png",
    --Name of image to be shown instead of the output, if defined
    --Necessary for crafting vehicles etc. where the output is an entity not an item

    output_tooltip = "Seamoth",
    --Human-readable name of craft (defaults to item description)
    --Necessary with output_icon

    recipe = {"sub_core:item_acidshroom 2", "sub_core:copper"}
    --List of input items as itemstrings
    --Unlike in the output, item counts function as expected
}
```

Inventory
---------

Subnodeica uses the Sfinv framework to define the inventory, however heavily modified to suit its needs. In general, the API should be the same as that of Sfinv, however be aware that the inventory is much larger and takes up the whole left side of the formspec.

* `sub_inv.make_formspec(player, context, content[, show_inv[, size]])`
    * Applies the inventory layout to the given formspec.
    * Parameters the same as `sfinv.make_formspec` which it is intended to replace.

* `sub_inv.add_databank_entry(player, name, text[, category[, subcategory]])`
    * Adds an entry to the Databank tab of the given player's inventory (stored in metadata).
    * `name`: the name of the entry in the menu on the left.
    * `text`: the entire text of the entry.
    * `category` and `subcategory` are used in the menu for categorisation.
    * There is intentionally no method for removing or changing an entry.

Subnodeica also reads the following custom fields in item definitions:

* `_equip`: a string specifying which equip slot it may be placed in.
    * Valid slots: `"head"`, `"body"`, `"feet"`, `"chips"` (x2), `"tank"`, `"hands"`.

* `_on_equip` and `_on_unequip`: functions to be called when equipped to the slot specified above or unequipped respectively.
    * The only argument to these functions is `player`, the ObjectRef of the player doing the action.

Misc
----

* `sub_core.give_item(item)`
    * Returns a function with the parameters `pos`, `node`, `user`, `itemstack`, to be used as an `on_rightclick` function by nodes.
    * This function gives the player a single item specified by `item`.

* `sub_core.drop_if_slash(item, no_break)`
    * Returns a function with the same format and usage as the above.
    * This function spawns the item as a dropped item, and then destroys the node unless `no_slash` is true.
    * Note that if `no_slash` is not true then the node must be waterloggable, in order to replace it with the correct water type.

* `sub_core.do_item_eat(food, water, itemstack, user)`
    * Attempts to use itemstack to restore the given percentages of hunger and thirst meters for the user.
    * If both meters are above 95% already then the itemstack will not be used and nothing will happen.
    * Note that hunger can overflow over 100% while thirst is capped at 100%.

* `sub_core.item_eat(food, water)`
    * A wrapper for the above, returns a function to be used in `on_place` and `on_secondary_use`.
    * Note that `minetest.item_eat` is also available to restore health.

* `sub_core.max_hunger`
* `sub_core.max_thirst`
* `sub_core.max_breath`
    * Time for hunger, thirst and breath to go from full to empty, in seconds.
    * Default to 3000, 2000 and 45 respectively.
    * Probably shouldn't be exposed, or at least as settings? I'll deal with this later.

Mobs
====

There are various sorts of mobs in Subnodeica, all made using the Mobkit framework. See the Mobkit API for more information.

This game's mob-related scripting is all in `sub_mobs`; the API functions are in `behaviors.lua` while the mobs are in their own files. Some similar mobs are put into the same file with each other: e.g. all scavengers and parasites are in `parasites.lua`, all small catchable fish are in `smallfish.lua`, etc.

Definition
----------

Entities are defined with `minetest.register_entity` as usual, and have all fields found in Minetest and Mobkit.

* `sub_mobs.actfunc(self, staticdata, dtime)`
    * Wrapper for `mobkit.actfunc` with a few extra features relating to HP. Recommended to be used in place of the Mobkit version.

* `sub_core.become_corpse(self)`
    * Removes object and replaces with a corpse, to be used in the entity `on_death` field.
    * Can be used by any entity, not just Mobkit ones.

The following fields are also used by Subnodeica:

```lua
{
    attack = {
        range = 1,
        --tool capabilities here
    }
    --Attack capabilities of entity, used by some behaviors
    --I think this might be from Mobkit as well

    explosion = {
        --same as attack
    }
    --Maximum damage capabilities of entity used by sub_mobs.explode

    corpse_despawn = false
    --If true, its corpse is despawned when the chunk is unloaded
    --Can be used by any entity
}
```

Spawning
--------

Currently mobs are only spawned during gameplay; I intend to add spawning on generation soon.

* `sub_mobs.registered_spawns`
    * List of registered spawn definitions.

* `sub_mobs.register_spawn(defs)`
    * Registers mob spawn definition.
    * No return value.

A mob spawn definition is a table with the following fields:

```lua
{
    name = "sub_mobs:peeper"
    --Name of entity to be spawned

    biomes = {"sub_core:shallows", "sub_core:forest"}
    --Biomes whose water the entity can spawn in

    nodes = {"sub_core:stone", "air"}
    --Other nodes which the entity can spawn in

    chance = 0.01
    reduction = 0.1
    --Chance of a spawn attempt succeeding and reduction for each active entity, as used by mobkit.get_spawn_pos_abr

    count = 1
    count_max = 3
    --Minimum and maximum number of objects to be spawned at once
    --count_max defaults to value of count

    height_min = -31000
    height_max = 0
    --Lower and upper bounds on height of spawn

    dist = 50
    --Distance of spawn from player
}
```

Behaviors
---------

All behaviors used in Subnodeica are custom-made - none of the default ones are used. In part this is because Mobkit does not recognise this game's water nodes as being water. Note also that many mobs define their own specialised local behavior functions. See the Mobkit API for explanation on the queue system which these build on.

* `sub_mobs.hq_fish_roam(self, priority, speed[, nopitch])`
    * Move around randomly underwater, frequently changing direction.
    * Works by repeatedly choosing a destination within 16m of itself and swimming towards it until sufficiently close.
    * `nopitch`: used by hoverfish, if true locks pitch to 0 (should probably replace with entity definition property).

* `sub_mobs.hq_fish_flee(self, priority, speed, obj[, jump])`
    * Flee erratically from `obj` in a similar manner to the above.
    * Internally mostly the same as above but offset away from the object's position.
    * `jump`: used by peepers, if true allows destination to be in the air, giving the appearance of leaping out of the water.

* `sub_mobs.hq_herd_roam(self, priority, speed[, herd_weight])`
    * Move around randomly, changing direction less often than the above.
    * Specifically, searches a 32m radius and is weighted upwards whereas `hq_fish_roam` is weighted downwards.
    * `herd_weight`: if defined, offsets search towards other nearby objects of the same type by the given amount.

* `sub_mobs.hq_big_roam(self, priority, speed)`
    * Move around randomly, changing direction even less often (64m radius, 32m vertically, weighted downwards).
    * Only really makes sense for leviathans such as reapers and ghosts.

* `sub_mobs.hq_water_chase(self, priority, speed, turn_rate, obj)`
    * Swim directly towards `obj` and attempt to attack upon coming in range.
    * Uses a different pathing system: instead of choosing a destination and moving towards it, it constantly interpolates its rotation towards the object by the amount given in `turn_rate` and moves forward.
    * Only attacks if the `attack` field is defined in the luaentity table, otherwise just closely follows the object; see below.

Misc
----

* `sub_mobs.containsi(table, value)`
    * Returns whether value is in an array-like table.

* `sub_mobs.is_larger(self, obj)`
    * Returns whether ObjectRef `obj` (can be player) is larger than luaentity `self`.
    * Used in brain functions of small fish to decide whether to flee from something.

* `sub_mobs.in_water(pos)`
    * Returns whether node at pos should be considered water (and therefore accessible) for pathfinding purposes, as defined by whether it has the group `pathfind_water`.
    * Used by most behaviors working on the destination pattern rather than the rotation pattern.

* `sub_mobs.check_in_water(self)`
    * Returns whether luaentity `self` is in water, for use in brain functions.
    * If not, it also makes it fall down and clears the high queue.

* `sub_mobs.turn_to(rot, dest_rot, turn_rate)`
    * Returns the rotation vector `rot` interpolated towards `dest_rot` no further than the scalar `turn_rate`.
    * Accounts for the split in yaw at plus-minus pi.
    * Used by most behaviors working on the rotation pattern.

* `sub_mobs.explode(self[, pos])`
    * Causes an explosion at `pos` (defaults to `self.object:get_pos()`), damaging nearby entities but not nodes depending on how close they are.
    * Damage and range given by `explosion` field in luaentity `self`.
    * Does not damage `self`; if you want to damage or remove it then that must be done separately.

More Misc
=========

Waypoints
---------

The mod `sub_nav` adds a global waypoint system for Subnautica's locator beacons, stored using mod storage. API may be found in `sub_nav/waypoints.lua`.

* `sub_nav.set_waypoint(pos, defs)`
    * Adds a waypoint at `pos`, defined by `defs`.
    * Returns an ID which may be used with other functions. Must be stored if you want to be able to do anything with it later.

* `sub_nav.remove_waypoint(id)`
    * Removes the waypoint with ID given by `id`.
    * If the waypoint does not exist, nothing happens.

* `sub_nav.move_waypoint(id, pos)`
    * Moves the waypoint with ID given by `id` to `pos`, if it exists. Vehicles should probably do this every step.
    * Returns whether the waypoint existed.

* `sub_nav.waypoint_pairs()`
    * Returns an iterator function and a table, to be used in a `for` loop as such:
        ```lua
        for pos, defs in sub_nav.waypoint_pairs() do
            --Stuff to be done for each waypoint
        end
        ```

* `sub_nav.registered_on_loads`
    * List of functions to be called on load. See below.

* `sub_nav.register_on_load(function())`
    * Registers a function to be called when the waypoint storage is initialised for the first time.
    * Should be used to add starting waypoints like the one for Lifepod 5.

* `sub_navs.update(player)`
    * Updates waypoint display for given player.
    * Called automatically on join.

* `sub_navs.update_all()`
    * Calls `sub_nav.update` for every connected player.
    * Called every step.

Vehicles
--------

Functions relating to vehicles are in `sub_vehicles/init.lua`.

* `sub_vehicles.add_huds(player, vehicle)`
    * Adds HUD showing vehicle health to player, to be called on entering a vehicle.
    * No return value, IDs are stored internally.

* `sub_vehicles.remove_huds(player)`
    * Removes vehicle HUDs from player, to be called on exiting a vehicle.
    * Assumes the HUDs are there, if not it may throw an exception.

* `sub_vehicles.update_huds(player)`
    * Updates vehicle HUDs for player, to be called on step.
    * Gets the vehicle from the player's attach.

WIP
===