local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local controller = deps.controller

local definition = {
    key = "I",
    label = "Tartarus",
    region = "Underworld",
    ui = "mods/ui/biomes/i_tartarus.lua",
    ui3 = "mods/ui3/biomes/i_tartarus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.minibossDepth("RatCatcher", {
        roomKey = "I_MiniBoss01",
        label = "The Verminancer",
        controller = controller.modeRange("MiniBossRatCatcher", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossRatCatcher",
            rangeAlias = "PackedMiniBossRatCatcher",
            min = 3,
            max = 7,
        }),
    }),
    room.minibossDepth("GoldElemental", {
        roomKey = "I_MiniBoss02",
        label = "Goldwrath",
        controller = controller.modeRange("MiniBossGoldElemental", {
            primitive = "minibossDepth",
            modeAlias = "ModeMiniBossGoldElemental",
            rangeAlias = "PackedMiniBossGoldElemental",
            min = 3,
            max = 7,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Nemesis", {
        controller = controller.modeRange("NPCNemesisTartarus", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCNemesisTartarus",
            rangeAlias = "PackedNPCNemesisTartarus",
            min = 4,
            max = 10,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
