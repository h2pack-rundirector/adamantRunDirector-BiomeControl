local deps = ...
local catalog = deps.catalog
local controlDefs = deps.controlDefs

local definition = {
    key = "I",
    label = "Tartarus",
    region = "Underworld",
    logic = "mods/logic/biomes/i_tartarus.lua",
    ui = "mods/ui/biomes/i_tartarus.lua",
}

local room = catalog.room(definition)
local npc = catalog.npc(definition)

local controls = {
    MiniBossRatCatcher = controlDefs.modeWithRange("MiniBossRatCatcher", {
        min = 3,
        max = 7,
    }),
    MiniBossGoldElemental = controlDefs.modeWithRange("MiniBossGoldElemental", {
        min = 3,
        max = 7,
    }),
    NPCNemesisTartarus = controlDefs.modeWithRange("NPCNemesisTartarus", {
        min = 4,
        max = 10,
    }),
}

local rooms = catalog.rooms({
    room.minibossDepth("RatCatcher", {
        roomKey = "I_MiniBoss01",
        label = "The Verminancer",
        controlName = "MiniBossRatCatcher",
    }),
    room.minibossDepth("GoldElemental", {
        roomKey = "I_MiniBoss02",
        label = "Goldwrath",
        controlName = "MiniBossGoldElemental",
    }),
})

local npcs = catalog.npcs({
    npc("Nemesis", {
        controlName = "NPCNemesisTartarus",
    }),
})

return catalog.biome(definition, {
    rooms = rooms,
    npcs = npcs,
    controlDeclarations = controls,
})
