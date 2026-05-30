local deps = ...
local builder = deps.builder
local catalog = deps.catalog
local settings = deps.settings
local definitions = deps.definitions

local EPHYRA_STORY_MODE_OPTIONS = { "default", "disabled", "forced" }
local EPHYRA_STORY_MODE_DISPLAY = {
    default = "Default",
    forced = "Forced",
    disabled = "Disabled",
}

local EPHYRA_MINIBOSS_MODE_OPTIONS = { "default", "satyr_crossbow", "boar", "disabled" }
local EPHYRA_MINIBOSS_MODE_DISPLAY = {
    default = "Default",
    satyr_crossbow = "Force Satyr Champion",
    boar = "Force Erymanthian Boar",
    disabled = "Disable Both",
}

local subRoomRewardOptions = {
    { bit = 0,  label = "Max Mana Small",         name = "MaxManaDropSmall" },
    { bit = 1,  label = "Max Health Small",       name = "MaxHealthDropSmall" },
    { bit = 2,  label = "Empty Max Health Small", name = "EmptyMaxHealthSmallDrop" },
    { bit = 3,  label = "Tiny Money",             name = "RoomMoneyTinyDrop" },
    { bit = 4,  label = "Air Boost",              name = "AirBoost" },
    { bit = 5,  label = "Earth Boost",            name = "EarthBoost" },
    { bit = 6,  label = "Fire Boost",             name = "FireBoost" },
    { bit = 7,  label = "Water Boost",            name = "WaterBoost" },
    { bit = 8,  label = "Gift",                   name = "GiftDrop" },
    { bit = 9,  label = "Meta Currency",          name = "MetaCurrencyDrop" },
    { bit = 10, label = "Card Points",            name = "MetaCardPointsCommonDrop" },
    { bit = 11, label = "Max Health",             name = "MaxHealthDrop" },
    { bit = 12, label = "Max Mana",               name = "MaxManaDrop" },
    { bit = 13, label = "Stack Upgrade",          name = "StackUpgrade" },
    { bit = 14, label = "Money",                  name = "RoomMoneyDrop" },
    { bit = 15, label = "Minor Talent",           name = "MinorTalentDrop" },
}

local subRoomRewardsHardOptions = {
    { bit = 0, label = "Max Health",    name = "MaxHealthDrop" },
    { bit = 1, label = "Max Mana",      name = "MaxManaDrop" },
    { bit = 2, label = "Stack Upgrade", name = "StackUpgrade" },
    { bit = 3, label = "Money",         name = "RoomMoneyDrop" },
}

local function buildHubRewardReplacementOptions()
    local values = { "" }
    local displayValues = {
        [""] = "Hermes (Default)",
    }

    for _, god in ipairs(definitions.priorityGods or {}) do
        values[#values + 1] = god.lootKey
        displayValues[god.lootKey] = god.label
    end

    return values, displayValues
end

local definition = {
    key = "N",
    label = "Ephyra",
    region = "Surface",
    logic = "mods/logic/biomes/n_ephyra.lua",
    ui = "mods/ui/biomes/n_ephyra.lua",
}

local npc = builder.npc(definition)
local hubRewardReplacementValues, hubRewardReplacementDisplayValues = buildHubRewardReplacementOptions()

local rooms = catalog.rooms({})

local npcs = catalog.npcs({
    npc("Artemis", {
        groupKey = "ArtemisSurface",
        setting = settings.modeWithRange("NPCArtemisEphyra", {
            min = 4,
            max = 10,
        }),
    }),
    npc("Heracles", {
        setting = settings.modeWithRange("NPCHeraclesEphyra", {
            min = 0,
            max = 10,
        }),
    }),
})

local controls = catalog.controls({
    settings.mode("EphyraStoryMode", {
        label = "Story",
        values = EPHYRA_STORY_MODE_OPTIONS,
        displayValues = EPHYRA_STORY_MODE_DISPLAY,
        default = "default",
        helpText = "(Default lets the game decide, Forced guarantees Medea when normally eligible, Disabled suppresses it)",
    }),
    settings.mode("EphyraMiniBossMode", {
        label = "Miniboss",
        values = EPHYRA_MINIBOSS_MODE_OPTIONS,
        displayValues = EPHYRA_MINIBOSS_MODE_DISPLAY,
        default = "default",
        helpText = "(Choose which Ephyra miniboss can appear, or disable both)",
    }),
    settings.choice("ReplaceHermesInEphyra", {
        label = "Hub Hermes Replacement",
        type = "string",
        values = hubRewardReplacementValues,
        displayValues = hubRewardReplacementDisplayValues,
        default = "",
        maxLen = 64,
        helpText = "(Replace the Hermes slot in Ephyra HubRewards with another god or remove it)",
    }),
    settings.packedSet("PackedBannedEphyraSubRoomRewards", {
        label = "SubRoomRewards",
        options = subRoomRewardOptions,
        helpText = "(Checked rewards are banned from normal Ephyra subroom reward pools)",
    }),
    settings.packedSet("PackedBannedEphyraSubRoomRewardsHard", {
        label = "SubRoomRewardsHard",
        options = subRoomRewardsHardOptions,
        helpText = "(Checked rewards are banned from hard Ephyra subroom reward pools)",
    }),
})

return catalog.biomeBundle(definition, {
    rooms = rooms,
    npcs = npcs,
    controls = controls,
})
