local deps = ...
local catalog = deps.catalog
local controlDefs = deps.controlDefs

local definition = {
    key = "P",
    label = "Olympus",
    region = "Surface",
    logic = "mods/logic/biomes/p_olympus.lua",
    ui = "mods/ui/biomes/p_olympus.lua",
}

local room = catalog.room(definition)
local npc = catalog.npc(definition)

local controls = {
    StoryDionysus = controlDefs.modeWithRange("StoryDionysus", {
        min = 3,
        max = 7,
    }),
    FountainOlympus = controlDefs.modeWithRange("FountainOlympus", {
        min = 4,
        max = 7,
    }),
    ShopOlympus = controlDefs.modeWithRange("ShopOlympus", {
        min = 5,
        max = 7,
    }),
    MiniBossTalos = controlDefs.modeWithRange("MiniBossTalos", {
        min = 4,
        max = 7,
    }),
    MiniBossDragon = controlDefs.modeWithRange("MiniBossDragon", {
        min = 4,
        max = 7,
    }),
    NPCHeraclesOlympus = controlDefs.modeWithRange("NPCHeraclesOlympus", {
        min = 0,
        max = 10,
    }),
    NPCAthenaOlympus = controlDefs.modeWithRange("NPCAthenaOlympus", {
        min = 4,
        max = 8,
    }),
    NPCIcarusOlympus = controlDefs.modeWithRange("NPCIcarusOlympus", {
        min = 3,
        max = 8,
    }),
}

local rooms = catalog.rooms({
    room.story("Dionysus", {
        roomKey = "P_Story01",
        controlName = "StoryDionysus",
    }),
    room.fountain({
        roomKey = "P_Reprieve01",
        controlName = "FountainOlympus",
    }),
    room.shop({
        roomKey = "P_Shop01",
        controlName = "ShopOlympus",
    }),
    room.minibossDepth("Talos", {
        roomKey = "P_MiniBoss01",
        label = "Talos",
        controlName = "MiniBossTalos",
    }),
    room.minibossDepth("Dragon", {
        roomKey = "P_MiniBoss02",
        label = "Mega-Dracon",
        controlName = "MiniBossDragon",
    }),
})

local npcs = catalog.npcs({
    npc("Heracles", {
        controlName = "NPCHeraclesOlympus",
    }),
    npc("Athena", {
        controlName = "NPCAthenaOlympus",
    }),
    npc("Icarus", {
        controlName = "NPCIcarusOlympus",
    }),
})

return catalog.biome(definition, {
    rooms = rooms,
    npcs = npcs,
    controlDeclarations = controls,
})
