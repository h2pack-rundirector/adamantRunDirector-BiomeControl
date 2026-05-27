local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local controller = deps.controller

local definition = {
    key = "G",
    label = "Oceanus",
    region = "Underworld",
    logic = "mods/logic3/biomes/g_oceanus.lua",
    ui = "mods/ui/biomes/g_oceanus.lua",
    ui3 = "mods/ui3/biomes/g_oceanus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Narcissus", {
        controller = controller.modeRange("StoryNarcissus", {
            primitive = "storyModeRange",
            modeAlias = "ModeStoryNarcissus",
            rangeAlias = "PackedStoryNarcissus",
            min = 3,
            max = 6,
        }),
    }),
    room.trial({
        controller = controller.modeRange("TrialOceanus", {
            primitive = "trialModeRange",
            modeAlias = "ModeTrialOceanus",
            rangeAlias = "PackedTrialOceanus",
            min = 3,
            max = 7,
        }),
    }),
    room.fountain({
        controller = controller.modeRange("FountainOceanus", {
            primitive = "roomModeRange",
            modeAlias = "ModeFountainOceanus",
            rangeAlias = "PackedFountainOceanus",
            min = 4,
            max = 6,
        }),
    }),
    room.shop({
        controller = controller.modeRange("ShopOceanus", {
            primitive = "roomModeRange",
            modeAlias = "ModeShopOceanus",
            rangeAlias = "PackedShopOceanus",
            min = 3,
            max = 6,
        }),
    }),
    room.minibossDepth("WaterUnit", {
        roomKey = "G_MiniBoss01",
        label = "Deep Serpent",
        controller = controller.modeRange("MiniBossWaterUnit", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossWaterUnit",
            rangeAlias = "PackedMiniBossWaterUnit",
            min = 4,
            max = 7,
        }),
    }),
    room.minibossDepth("Crawler", {
        roomKey = "G_MiniBoss02",
        label = "King Vermin",
        controller = controller.modeRange("MiniBossCrawler", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossCrawler",
            rangeAlias = "PackedMiniBossCrawler",
            min = 4,
            max = 7,
        }),
    }),
    room.minibossDepth("Jellyfish", {
        roomKey = "G_MiniBoss03",
        label = "Hellifish",
        controller = controller.modeRange("MiniBossJellyfish", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossJellyfish",
            rangeAlias = "PackedMiniBossJellyfish",
            min = 4,
            max = 7,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Artemis", {
        groupKey = "ArtemisUnderworld",
        controller = controller.modeRange("NPCArtemisOceanus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCArtemisOceanus",
            rangeAlias = "PackedNPCArtemisOceanus",
            min = 4,
            max = 10,
        }),
    }),
    npc("Nemesis", {
        controller = controller.modeRange("NPCNemesisOceanus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCNemesisOceanus",
            rangeAlias = "PackedNPCNemesisOceanus",
            min = 4,
            max = 10,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
