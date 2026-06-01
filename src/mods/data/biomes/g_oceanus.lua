local deps = ...
local catalog = deps.catalog
local controlDefs = deps.controlDefs

local definition = {
    key = "G",
    label = "Oceanus",
    region = "Underworld",
    logic = "mods/logic/biomes/g_oceanus.lua",
    ui = "mods/ui/biomes/g_oceanus.lua",
}

local room = catalog.room(definition)
local npc = catalog.npc(definition)

local controls = {
    StoryNarcissus = controlDefs.modeWithRange("StoryNarcissus", {
        min = 3,
        max = 6,
    }),
    TrialOceanus = controlDefs.modeWithRange("TrialOceanus", {
        min = 3,
        max = 7,
    }),
    FountainOceanus = controlDefs.modeWithRange("FountainOceanus", {
        min = 4,
        max = 6,
    }),
    ShopOceanus = controlDefs.modeWithRange("ShopOceanus", {
        min = 3,
        max = 6,
    }),
    MiniBossWaterUnit = controlDefs.modeWithRange("MiniBossWaterUnit", {
        min = 4,
        max = 7,
    }),
    MiniBossCrawler = controlDefs.modeWithRange("MiniBossCrawler", {
        min = 4,
        max = 7,
    }),
    MiniBossJellyfish = controlDefs.modeWithRange("MiniBossJellyfish", {
        min = 4,
        max = 7,
    }),
    NPCArtemisOceanus = controlDefs.modeWithRange("NPCArtemisOceanus", {
        min = 4,
        max = 10,
    }),
    NPCNemesisOceanus = controlDefs.modeWithRange("NPCNemesisOceanus", {
        min = 4,
        max = 10,
    }),
}

local rooms = catalog.rooms({
    room.story("Narcissus", {
        roomKey = "G_Story01",
        controlName = "StoryNarcissus",
    }),
    room.trial({
        controlName = "TrialOceanus",
    }),
    room.fountain({
        roomKey = "G_Reprieve01",
        controlName = "FountainOceanus",
    }),
    room.shop({
        roomKey = "G_Shop01",
        controlName = "ShopOceanus",
    }),
    room.minibossDepth("WaterUnit", {
        roomKey = "G_MiniBoss01",
        label = "Deep Serpent",
        controlName = "MiniBossWaterUnit",
    }),
    room.minibossDepth("Crawler", {
        roomKey = "G_MiniBoss02",
        label = "King Vermin",
        controlName = "MiniBossCrawler",
    }),
    room.minibossDepth("Jellyfish", {
        roomKey = "G_MiniBoss03",
        label = "Hellifish",
        controlName = "MiniBossJellyfish",
    }),
})

local npcs = catalog.npcs({
    npc("Artemis", {
        groupKey = "ArtemisUnderworld",
        controlName = "NPCArtemisOceanus",
    }),
    npc("Nemesis", {
        controlName = "NPCNemesisOceanus",
    }),
})

return catalog.biome(definition, {
    rooms = rooms,
    npcs = npcs,
    controlDeclarations = controls,
})
