local deps = ...
local catalog = deps.catalog
local controlDefs = deps.controlDefs

local THESSALY_MINIBOSS_MODE_OPTIONS = { "default", "charybdis", "captain", "disabled" }
local THESSALY_MINIBOSS_MODE_DISPLAY = {
    default = "Default",
    charybdis = "Force Charybdis",
    captain = "Force The Yargonaut",
    disabled = "Disable Both",
}

local definition = {
    key = "O",
    label = "Thessaly",
    region = "Surface",
    logic = "mods/logic/biomes/o_thessaly.lua",
    ui = "mods/ui/biomes/o_thessaly.lua",
}

local room = catalog.room(definition)
local npc = catalog.npc(definition)

local controls = {
    StoryCirce = controlDefs.modeWithRange("StoryCirce", {
        min = 4,
        max = 5,
    }),
    TrialThessaly = controlDefs.modeWithRange("TrialThessaly", {
        min = 2,
        max = 6,
    }),
    FountainThessaly = controlDefs.modeWithRange("FountainThessaly", {
        min = 3,
        max = 5,
    }),
    ShopThessaly = controlDefs.modeWithRange("ShopThessaly", {
        min = 4,
        max = 5,
    }),
    NPCHeraclesThessaly = controlDefs.modeWithRange("NPCHeraclesThessaly", {
        min = 0,
        max = 10,
    }),
    NPCIcarusThessaly = controlDefs.modeWithRange("NPCIcarusThessaly", {
        min = 3,
        max = 8,
    }),
    ThessalyMiniBossMode = controlDefs.modeWithRange("ThessalyMiniBossMode", {
        label = "Miniboss",
        roomGroup = "MiniBoss",
        values = THESSALY_MINIBOSS_MODE_OPTIONS,
        displayValues = THESSALY_MINIBOSS_MODE_DISPLAY,
        default = "default",
        min = 3,
        max = 5,
        visibleWhen = {
            charybdis = true,
            captain = true,
        },
        helpText = "(Default lets the game decide, Forced selects one miniboss, Disabled suppresses both)",
    }),
}

local rooms = catalog.rooms({
    room.story("Circe", {
        roomKey = "O_Story01",
        controlName = "StoryCirce",
    }),
    room.trial({
        roomKey = "O_Devotion01",
        controlName = "TrialThessaly",
    }),
    room.fountain({
        roomKey = "O_Reprieve01",
        controlName = "FountainThessaly",
    }),
    room.shop({
        roomKey = "O_Shop01",
        controlName = "ShopThessaly",
    }),
})

local npcs = catalog.npcs({
    npc("Heracles", {
        controlName = "NPCHeraclesThessaly",
    }),
    npc("Icarus", {
        controlName = "NPCIcarusThessaly",
    }),
})

local controlRefs = catalog.controlRefs({
    "ThessalyMiniBossMode",
})

return catalog.biome(definition, {
    rooms = rooms,
    npcs = npcs,
    controlRefs = controlRefs,
    controlDeclarations = controls,
})
