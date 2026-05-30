local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local settings = deps.settings

local definition = {
    key = "I",
    label = "Tartarus",
    region = "Underworld",
    ui = "mods/ui/biomes/i_tartarus.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.minibossDepth("RatCatcher", {
        roomKey = "I_MiniBoss01",
        label = "The Verminancer",
        setting = settings.modeWithRange("MiniBossRatCatcher", {
            min = 3,
            max = 7,
        }),
    }),
    room.minibossDepth("GoldElemental", {
        roomKey = "I_MiniBoss02",
        label = "Goldwrath",
        setting = settings.modeWithRange("MiniBossGoldElemental", {
            min = 3,
            max = 7,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Nemesis", {
        setting = settings.modeWithRange("NPCNemesisTartarus", {
            min = 4,
            max = 10,
        }),
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
})
