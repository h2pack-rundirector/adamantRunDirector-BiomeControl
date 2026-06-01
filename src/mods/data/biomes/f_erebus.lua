local deps = ...
local catalog = deps.catalog
local controlDefs = deps.controlDefs

local definition = {
    key = "F",
    label = "Erebus",
    region = "Underworld",
    logic = "mods/logic/biomes/f_erebus.lua",
    ui = "mods/ui/biomes/f_erebus.lua",
}

local room = catalog.room(definition)
local npc = catalog.npc(definition)

local controls = {
    StoryArachne = controlDefs.modeWithRange("StoryArachne", {
        min = 4,
        max = 8,
    }),
    TrialErebus = controlDefs.modeWithRange("TrialErebus", {
        min = 6,
        max = 10,
    }),
    FountainErebus = controlDefs.modeWithRange("FountainErebus", {
        min = 4,
        max = 8,
    }),
    ShopErebus = controlDefs.modeWithRange("ShopErebus", {
        min = 4,
        max = 6,
    }),
    MiniBossTreant = controlDefs.modeWithRange("MiniBossTreant", {
        min = 4,
        max = 6,
    }),
    MiniBossFogEmitter = controlDefs.modeWithRange("MiniBossFogEmitter", {
        min = 4,
        max = 6,
    }),
    MiniBossAssassin = controlDefs.modeWithRange("MiniBossAssassin", {
        min = 4,
        max = 6,
    }),
    NPCArtemisErebus = controlDefs.modeWithRange("NPCArtemisErebus", {
        min = 4,
        max = 10,
    }),
    NPCNemesisErebus = controlDefs.modeWithRange("NPCNemesisErebus", {
        min = 4,
        max = 10,
    }),
}

local rooms = catalog.rooms({
    room.story("Arachne", {
        roomKey = "F_Story01",
        controlName = "StoryArachne",
    }),
    room.trial({
        controlName = "TrialErebus",
    }),
    room.fountain({
        roomKey = "F_Reprieve01",
        controlName = "FountainErebus",
    }),
    room.shop({
        roomKey = "F_Shop01",
        controlName = "ShopErebus",
    }),
    room.minibossDepth("Treant", {
        roomKey = "F_MiniBoss01",
        label = "Root-Stalker",
        controlName = "MiniBossTreant",
    }),
    room.minibossDepth("FogEmitter", {
        roomKey = "F_MiniBoss02",
        label = "Shadow-Spiller",
        controlName = "MiniBossFogEmitter",
    }),
    room.minibossDepth("Assassin", {
        roomKey = "F_MiniBoss03",
        label = "Master-Slicer",
        controlName = "MiniBossAssassin",
    }),
})

local npcs = catalog.npcs({
    npc("Artemis", {
        groupKey = "ArtemisUnderworld",
        controlName = "NPCArtemisErebus",
    }),
    npc("Nemesis", {
        controlName = "NPCNemesisErebus",
    }),
})

return catalog.biome(definition, {
    rooms = rooms,
    npcs = npcs,
    controlDeclarations = controls,
})
