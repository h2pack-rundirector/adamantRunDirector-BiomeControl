local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local controller = deps.controller

local definition = {
    key = "P",
    label = "Olympus",
    region = "Surface",
    ui = "mods/ui/biomes/p_olympus.lua",
    ui3 = "mods/ui3/biomes/p_olympus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Dionysus", {
        controller = controller.modeRange("StoryDionysus", {
            primitive = "storyModeRange",
            modeAlias = "ModeStoryDionysus",
            rangeAlias = "PackedStoryDionysus",
            min = 3,
            max = 7,
        }),
    }),
    room.fountain({
        controller = controller.modeRange("FountainOlympus", {
            primitive = "roomModeRange",
            modeAlias = "ModeFountainOlympus",
            rangeAlias = "PackedFountainOlympus",
            min = 4,
            max = 7,
        }),
    }),
    room.shop({
        controller = controller.modeRange("ShopOlympus", {
            primitive = "roomModeRange",
            modeAlias = "ModeShopOlympus",
            rangeAlias = "PackedShopOlympus",
            min = 5,
            max = 7,
        }),
    }),
    room.minibossDepth("Talos", {
        roomKey = "P_MiniBoss01",
        label = "Talos",
        controller = controller.modeRange("MiniBossTalos", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossTalos",
            rangeAlias = "PackedMiniBossTalos",
            min = 4,
            max = 7,
        }),
    }),
    room.minibossDepth("Dragon", {
        roomKey = "P_MiniBoss02",
        label = "Mega-Dracon",
        controller = controller.modeRange("MiniBossDragon", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossDragon",
            rangeAlias = "PackedMiniBossDragon",
            min = 4,
            max = 7,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Heracles", {
        controller = controller.modeRange("NPCHeraclesOlympus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCHeraclesOlympus",
            rangeAlias = "PackedNPCHeraclesOlympus",
            min = 0,
            max = 10,
        }),
    }),
    npc("Athena", {
        controller = controller.modeRange("NPCAthenaOlympus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCAthenaOlympus",
            rangeAlias = "PackedNPCAthenaOlympus",
            min = 4,
            max = 8,
        }),
    }),
    npc("Icarus", {
        controller = controller.modeRange("NPCIcarusOlympus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCIcarusOlympus",
            rangeAlias = "PackedNPCIcarusOlympus",
            min = 3,
            max = 8,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
