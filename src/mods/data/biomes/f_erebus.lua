local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local settings = deps.settings

local definition = {
    key = "F",
    label = "Erebus",
    region = "Underworld",
    logic = "mods/logic/biomes/f_erebus.lua",
    ui = "mods/ui/biomes/f_erebus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Arachne", {
        setting = settings.modeWithRange("StoryArachne", {
            min = 4,
            max = 8,
        }),
    }),
    room.trial({
        setting = settings.modeWithRange("TrialErebus", {
            min = 6,
            max = 10,
        }),
    }),
    room.fountain({
        setting = settings.modeWithRange("FountainErebus", {
            min = 4,
            max = 8,
        }),
    }),
    room.shop({
        setting = settings.modeWithRange("ShopErebus", {
            min = 4,
            max = 6,
        }),
    }),
    room.minibossDepth("Treant", {
        roomKey = "F_MiniBoss01",
        label = "Root-Stalker",
        setting = settings.modeWithRange("MiniBossTreant", {
            min = 4,
            max = 6,
        }),
    }),
    room.minibossDepth("FogEmitter", {
        roomKey = "F_MiniBoss02",
        label = "Shadow-Spiller",
        setting = settings.modeWithRange("MiniBossFogEmitter", {
            min = 4,
            max = 6,
        }),
    }),
    room.minibossDepth("Assassin", {
        roomKey = "F_MiniBoss03",
        label = "Master-Slicer",
        setting = settings.modeWithRange("MiniBossAssassin", {
            min = 4,
            max = 6,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Artemis", {
        groupKey = "ArtemisUnderworld",
        setting = settings.modeWithRange("NPCArtemisErebus", {
            min = 4,
            max = 10,
        }),
    }),
    npc("Nemesis", {
        setting = settings.modeWithRange("NPCNemesisErebus", {
            min = 4,
            max = 10,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
