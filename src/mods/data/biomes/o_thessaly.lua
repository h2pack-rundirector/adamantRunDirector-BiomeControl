local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local settings = deps.settings

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

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Circe", {
        setting = settings.modeWithRange("StoryCirce", {
            min = 4,
            max = 5,
        }),
    }),
    room.trial({
        setting = settings.modeWithRange("TrialThessaly", {
            min = 2,
            max = 6,
        }),
    }),
    room.fountain({
        setting = settings.modeWithRange("FountainThessaly", {
            min = 3,
            max = 5,
        }),
    }),
    room.shop({
        setting = settings.modeWithRange("ShopThessaly", {
            min = 4,
            max = 5,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Heracles", {
        setting = settings.modeWithRange("NPCHeraclesThessaly", {
            min = 0,
            max = 10,
        }),
    }),
    npc("Icarus", {
        setting = settings.modeWithRange("NPCIcarusThessaly", {
            min = 3,
            max = 8,
        }),
    }),
})

local controls = catalog.controls({
    settings.modeWithRange("ThessalyMiniBossMode", {
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
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
    controls = controls,
})
