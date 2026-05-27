local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local controller = deps.controller

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
    logic = "mods/logic3/biomes/o_thessaly.lua",
    ui = "mods/ui/biomes/o_thessaly.lua",
    ui3 = "mods/ui3/biomes/o_thessaly.lua",
}

local room = builder.room(definition)
local npc = builder.npc(definition)

local rooms = catalog.rooms({
    room.story("Circe", {
        controller = controller.modeRange("StoryCirce", {
            primitive = "storyModeRange",
            modeAlias = "ModeStoryCirce",
            rangeAlias = "PackedStoryCirce",
            min = 4,
            max = 5,
        }),
    }),
    room.trial({
        controller = controller.modeRange("TrialThessaly", {
            primitive = "trialModeRange",
            modeAlias = "ModeTrialThessaly",
            rangeAlias = "PackedTrialThessaly",
            min = 2,
            max = 6,
        }),
    }),
    room.fountain({
        controller = controller.modeRange("FountainThessaly", {
            primitive = "roomModeRange",
            modeAlias = "ModeFountainThessaly",
            rangeAlias = "PackedFountainThessaly",
            min = 3,
            max = 5,
        }),
    }),
    room.shop({
        controller = controller.modeRange("ShopThessaly", {
            primitive = "roomModeRange",
            modeAlias = "ModeShopThessaly",
            rangeAlias = "PackedShopThessaly",
            min = 4,
            max = 5,
        }),
    }),
})

local npcs = catalog.npcs({
    npc("Heracles", {
        controller = controller.modeRange("NPCHeraclesThessaly", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCHeraclesThessaly",
            rangeAlias = "PackedNPCHeraclesThessaly",
            min = 0,
            max = 10,
        }),
    }),
    npc("Icarus", {
        controller = controller.modeRange("NPCIcarusThessaly", {
            primitive = "npcModeRange",
            modeAlias = "ModeNPCIcarusThessaly",
            rangeAlias = "PackedNPCIcarusThessaly",
            min = 3,
            max = 8,
        }),
    }),
})

local controls = catalog.controls({
    controller.mode("ThessalyMiniBossMode", {
        primitive = "minibossSelector",
        label = "Miniboss",
        roomGroup = "MiniBoss",
        values = THESSALY_MINIBOSS_MODE_OPTIONS,
        displayValues = THESSALY_MINIBOSS_MODE_DISPLAY,
        default = "default",
        helpText = "(Default lets the game decide, Forced selects one miniboss, Disabled suppresses both)",
    }),
    controller.range("ForcedThessalyMiniBoss", {
        primitive = "forcedMinibossRange",
        label = "Forced Range",
        rangeAlias = "PackedForcedThessalyMiniBoss",
        min = 3,
        max = 5,
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
    controls = controls,
})
