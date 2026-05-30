local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local settings = deps.settings

local definition = {
    key = "H",
    label = "Fields",
    region = "Underworld",
    logic = "mods/logic/biomes/h_fields.lua",
    ui = "mods/ui/biomes/h_fields.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.minibossDepth("Vampire", {
        roomKey = "H_MiniBoss01",
        label = "Phantom",
        setting = settings.modeWithRange("MiniBossVampire", {
            min = 2,
            max = 4,
        }),
    }),
    room.minibossDepth("Lamia", {
        roomKey = "H_MiniBoss02",
        label = "Queen Lamia",
        setting = settings.modeWithRange("MiniBossLamia", {
            min = 2,
            max = 4,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Nemesis", {
        setting = settings.modeWithRange("NPCNemesisFields", {
            min = 4,
            max = 10,
        }),
    }),
})

local controls = catalog.controls({
    settings.flag("PreventEchoScam", {
        label = "Prevent Echo Scam",
        helpText = "(Prevent miniboss from spawning in same depth as Echo, which can prevent it from spawning at all)",
    }),
    settings.flag("ForceTwoRewardFieldsOpeners", {
        label = "Force 2 Rewards In First Two Rooms",
        helpText = "(Force normal H combat encounters to offer exactly 2 rewards at biome depth 1 and 2; " ..
            "vanilla 3-reward promotion resumes after depth 2)",
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
    controls = controls,
})
