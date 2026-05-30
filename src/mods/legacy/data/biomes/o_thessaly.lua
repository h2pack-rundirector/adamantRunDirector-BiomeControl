local THESSALY_MINIBOSS_MODE_OPTIONS = { "default", "charybdis", "captain", "disabled" }
local THESSALY_MINIBOSS_MODE_DISPLAY = {
    default = "Default",
    charybdis = "Force Charybdis",
    captain = "Force The Yargonaut",
    disabled = "Disable Both",
}

return {
    key = "O",
    label = "Thessaly",
    region = "Surface",
    logic = "mods/logic/biomes/o_thessaly.lua",
    ui = "mods/ui/biomes/o_thessaly.lua",
    rooms = {
        { id = "Circe", type = "Story", min = 4, max = 5 },
        { id = "Trial", type = "Trial", useRegionInKey = true, min = 2, max = 6 },
        { id = "Fountain", type = "Fountain", useRegionInKey = true, min = 3, max = 5 },
        { id = "Shop", type = "Shop", useRegionInKey = true, min = 4, max = 5 },
    },
    npcs = {
        { id = "Heracles", min = 0, max = 10 },
        { id = "Icarus", min = 3, max = 8 },
    },
    controls = {
        rangeFields = {
            {
                label = "Forced Range",
                rangeMinAlias = "PackedForcedThessalyMiniBossMin",
                rangeMaxAlias = "PackedForcedThessalyMiniBossMax",
                min = 3,
                max = 5,
            },
        },
        rooms = {
            {
                kind = "modeField",
                label = "Miniboss",
                roomGroup = "MiniBoss",
                modeKey = "ThessalyMiniBossMode",
                modeValues = THESSALY_MINIBOSS_MODE_OPTIONS,
                modeDisplayValues = THESSALY_MINIBOSS_MODE_DISPLAY,
                defaultMode = "default",
                helpText = "(Default lets the game decide, Forced selects one miniboss, Disabled suppresses both)",
            },
        },
    },
}
