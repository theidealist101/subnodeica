Subnodeica
==========

An attempt to recreate the popular survival and exploration game Subnautica in the Minetest engine.

This is very much an early work in progress, expect almost everything about it to change at any time without notice. Consequently it is not recommended to create mods for it or forks of it at this stage, and for the same reason the APIs are not yet documented. (I WILL document them someday!)

Disclaimer: This project is not affiliated with or endorsed by the creators of Subnautica. It is merely the personal project of a passionate fan.

Copyright (C) 2024 theidealist (theidealistmusic@gmail.com)

Installation
------------

Like any other Minetest game: download and place it in your Minetest "games" folder. Probably requires Minetest 5.8.0 or higher.

Features
--------

As stated above this game is in early development, but these are the features currently implemented:

- Custom mapgen supporting biomes of different terrain shapes and heights
- Several major biomes: Safe Shallows, Kelp Forest, Grassy Plateaus, each with their own terrain and resources
- A crafting system using the fabricator, not many recipes exist yet but it is easily extendable
- Most of the mobs inhabiting the aforementioned biomes, with their own behaviours made using the Mobkit API
- A basic version of Lifepod 5 which the player spawns within

These features I expect to add in the near future:

- More diverse terrain features (e.g. pillars in Plateaus, floating land in Underwater Islands) and narrow surface caves
- More biomes, including cavern biomes such as the Jellyshroom Caves
- More decorations for the main biomes
- Debris and scannable blueprints and metal salvage from the Aurora
- Stalkers, the only major mob of these three biomes to not yet be implemented, as it needs metal salvage to play with
- Improvements and fixes for mob behaviours, like floating mobs, fish which sometimes try to swim into the ground, gasopods which sleep when they shouldn't, reefbacks which are really bad at avoiding terrain, etc.
- Putting more stuff in Lifepod 5 and making it actually usable

Probably next on the list of big features are a proper inventory and surface caves. (I've made crashfish and mesmers but they don't spawn yet.)

Also note that the bioluminescence mechanic does not fully work yet, as Minetest does not have glow on nodes or any way of making only some parts of a texture glow; I intend to get this added to Minetest. There are also no animations on models, as I'm waiting for .gltf support first.