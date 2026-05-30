local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local settings = deps.settings

local definition = {
    key = "P",
    label = "Olympus",
    region = "Surface",
    ui = "mods/ui/biomes/p_olympus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Dionysus", {
        setting = settings.modeWithRange("StoryDionysus", {
            min = 3,
            max = 7,
        }),
    }),
    room.fountain({
        setting = settings.modeWithRange("FountainOlympus", {
            min = 4,
            max = 7,
        }),
    }),
    room.shop({
        setting = settings.modeWithRange("ShopOlympus", {
            min = 5,
            max = 7,
        }),
    }),
    room.minibossDepth("Talos", {
        roomKey = "P_MiniBoss01",
        label = "Talos",
        setting = settings.modeWithRange("MiniBossTalos", {
            min = 4,
            max = 7,
        }),
    }),
    room.minibossDepth("Dragon", {
        roomKey = "P_MiniBoss02",
        label = "Mega-Dracon",
        setting = settings.modeWithRange("MiniBossDragon", {
            min = 4,
            max = 7,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Heracles", {
        setting = settings.modeWithRange("NPCHeraclesOlympus", {
            min = 0,
            max = 10,
        }),
    }),
    npc("Athena", {
        setting = settings.modeWithRange("NPCAthenaOlympus", {
            min = 4,
            max = 8,
        }),
    }),
    npc("Icarus", {
        setting = settings.modeWithRange("NPCIcarusOlympus", {
            min = 3,
            max = 8,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
