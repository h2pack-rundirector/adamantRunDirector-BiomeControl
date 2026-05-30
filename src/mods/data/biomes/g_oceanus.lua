local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local settings = deps.settings

local definition = {
    key = "G",
    label = "Oceanus",
    region = "Underworld",
    logic = "mods/logic/biomes/g_oceanus.lua",
    ui = "mods/ui/biomes/g_oceanus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Narcissus", {
        setting = settings.modeWithRange("StoryNarcissus", {
            min = 3,
            max = 6,
        }),
    }),
    room.trial({
        setting = settings.modeWithRange("TrialOceanus", {
            min = 3,
            max = 7,
        }),
    }),
    room.fountain({
        setting = settings.modeWithRange("FountainOceanus", {
            min = 4,
            max = 6,
        }),
    }),
    room.shop({
        setting = settings.modeWithRange("ShopOceanus", {
            min = 3,
            max = 6,
        }),
    }),
    room.minibossDepth("WaterUnit", {
        roomKey = "G_MiniBoss01",
        label = "Deep Serpent",
        setting = settings.modeWithRange("MiniBossWaterUnit", {
            min = 4,
            max = 7,
        }),
    }),
    room.minibossDepth("Crawler", {
        roomKey = "G_MiniBoss02",
        label = "King Vermin",
        setting = settings.modeWithRange("MiniBossCrawler", {
            min = 4,
            max = 7,
        }),
    }),
    room.minibossDepth("Jellyfish", {
        roomKey = "G_MiniBoss03",
        label = "Hellifish",
        setting = settings.modeWithRange("MiniBossJellyfish", {
            min = 4,
            max = 7,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Artemis", {
        groupKey = "ArtemisUnderworld",
        setting = settings.modeWithRange("NPCArtemisOceanus", {
            min = 4,
            max = 10,
        }),
    }),
    npc("Nemesis", {
        setting = settings.modeWithRange("NPCNemesisOceanus", {
            min = 4,
            max = 10,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
