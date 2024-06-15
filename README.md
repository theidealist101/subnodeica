Subnodeica
==========

An attempt to recreate the popular survival and exploration game Subnautica in the Minetest engine.

This is very much an early work in progress, expect almost everything about it to change at any time without notice. Consequently it is not recommended to create mods for it or forks of it at this stage, and for the same reason the APIs are not yet fully documented. (I'm working on it!)

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
- An easily extendable crafting system using the fabricator
- Most of the mobs inhabiting the aforementioned biomes, with their own behaviours made using the Mobkit API
- A basic version of Lifepod 5 which the player spawns within
- A working custom inventory and HUD with hunger and thirst
- Navigational features including beacons, depth meter and compass
- One vehicle, the Seamoth, craftable using a mobile vehicle bay

Goals
-----

The following must be achieved before I consider applying to ContentDB:

- The following biomes fully fleshed out with all decorations, terrain features (floaters, pillars, etc.) and carver caves: Safe Shallows, Kelp Forest, Grassy Plateaus, Jellyshroom Caves
- Structures to populate these: wrecks, scatters and the first Degasi seabase
- Fully operational Lifepod 5 with hatches, storage, and preferably intro cutscene
- At least minimal seabase construction stuff, with basic corridors, hatches, multipurpose rooms, and power
- Bioluminescence on decoration nodes (requires engine changes)
- Particles, sounds and animations for quality of life (animations waiting for .gltf support)