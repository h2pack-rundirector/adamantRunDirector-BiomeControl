local deps = ...
local catalog = deps.catalog
local controlDefs = deps.controlDefs

local definition = {
    key = "H",
    label = "Fields",
    region = "Underworld",
    logic = "mods/logic/biomes/h_fields.lua",
    ui = "mods/ui/biomes/h_fields.lua",
}

local room = catalog.room(definition)
local npc = catalog.npc(definition)

local controls = {
    MiniBossVampire = controlDefs.modeWithRange("MiniBossVampire", {
        min = 2,
        max = 4,
    }),
    MiniBossLamia = controlDefs.modeWithRange("MiniBossLamia", {
        min = 2,
        max = 4,
    }),
    NPCNemesisFields = controlDefs.modeWithRange("NPCNemesisFields", {
        min = 4,
        max = 10,
    }),
    PreventEchoScam = controlDefs.flag("PreventEchoScam", {
        label = "Prevent Echo Scam",
        helpText = "(Prevent miniboss from spawning in same depth as Echo, which can prevent it from spawning at all)",
    }),
    ForceTwoRewardFieldsOpeners = controlDefs.flag("ForceTwoRewardFieldsOpeners", {
        label = "Force 2 Rewards In First Two Rooms",
        helpText = "(Force normal H combat encounters to offer exactly 2 rewards at biome depth 1 and 2; " ..
            "vanilla 3-reward promotion resumes after depth 2)",
    }),
}

local rooms = catalog.rooms({
    room.minibossDepth("Vampire", {
        roomKey = "H_MiniBoss01",
        label = "Phantom",
        controlName = "MiniBossVampire",
    }),
    room.minibossDepth("Lamia", {
        roomKey = "H_MiniBoss02",
        label = "Queen Lamia",
        controlName = "MiniBossLamia",
    }),
})

local npcs = catalog.npcs({
    npc("Nemesis", {
        controlName = "NPCNemesisFields",
    }),
})

local controlRefs = catalog.controlRefs({
    "PreventEchoScam",
    "ForceTwoRewardFieldsOpeners",
})

return catalog.biome(definition, {
    rooms = rooms,
    npcs = npcs,
    controlRefs = controlRefs,
    controlDeclarations = controls,
})
