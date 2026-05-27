local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local controller = deps.controller

local definition = {
    key = "F",
    label = "Erebus",
    region = "Underworld",
    logic = "mods/logic3/biomes/f_erebus.lua",
    ui = "mods/ui/biomes/f_erebus.lua",
    ui3 = "mods/ui3/biomes/f_erebus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Arachne", {
        controller = controller.modeRange("StoryArachne", {
            primitive = "storyModeRange",
            modeAlias = "ModeStoryArachne",
            rangeAlias = "PackedStoryArachne",
            min = 4,
            max = 8,
        }),
    }),
    room.trial({
        controller = controller.modeRange("TrialErebus", {
            primitive = "trialModeRange",
            modeAlias = "ModeTrialErebus",
            rangeAlias = "PackedTrialErebus",
            min = 6,
            max = 10,
        }),
    }),
    room.fountain({
        controller = controller.modeRange("FountainErebus", {
            primitive = "roomModeRange",
            modeAlias = "ModeFountainErebus",
            rangeAlias = "PackedFountainErebus",
            min = 4,
            max = 8,
        }),
    }),
    room.shop({
        controller = controller.modeRange("ShopErebus", {
            primitive = "roomModeRange",
            modeAlias = "ModeShopErebus",
            rangeAlias = "PackedShopErebus",
            min = 4,
            max = 6,
        }),
    }),
    room.minibossDepth("Treant", {
        roomKey = "F_MiniBoss01",
        label = "Root-Stalker",
        controller = controller.modeRange("MiniBossTreant", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossTreant",
            rangeAlias = "PackedMiniBossTreant",
            min = 4,
            max = 6,
        }),
    }),
    room.minibossDepth("FogEmitter", {
        roomKey = "F_MiniBoss02",
        label = "Shadow-Spiller",
        controller = controller.modeRange("MiniBossFogEmitter", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossFogEmitter",
            rangeAlias = "PackedMiniBossFogEmitter",
            min = 4,
            max = 6,
        }),
    }),
    room.minibossDepth("Assassin", {
        roomKey = "F_MiniBoss03",
        label = "Master-Slicer",
        controller = controller.modeRange("MiniBossAssassin", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossAssassin",
            rangeAlias = "PackedMiniBossAssassin",
            min = 4,
            max = 6,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Artemis", {
        groupKey = "ArtemisUnderworld",
        controller = controller.modeRange("NPCArtemisErebus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCArtemisErebus",
            rangeAlias = "PackedNPCArtemisErebus",
            min = 4,
            max = 10,
        }),
    }),
    npc("Nemesis", {
        controller = controller.modeRange("NPCNemesisErebus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCNemesisErebus",
            rangeAlias = "PackedNPCNemesisErebus",
            min = 4,
            max = 10,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
