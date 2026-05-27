local baseStorage = {}

function baseStorage.build()
    return {
        { type = "bool",   alias = "OnlyAllowForcedEncounters",       default = false },
        { type = "bool",   alias = "IgnoreMaxDepth",                 default = false },
        { type = "int",    alias = "NPCSpacing",                     default = 6, min = 1, max = 12 },
        { type = "bool",   alias = "PrioritizeSpecificRewardEnabled", default = false },
        { type = "string", alias = "PriorityBiome1",                 default = "" },
        { type = "string", alias = "PriorityBiome2",                 default = "" },
        { type = "string", alias = "PriorityBiome3",                 default = "" },
        { type = "string", alias = "PriorityBiome4",                 default = "" },
        { type = "bool",   alias = "PrioritizeTrialRewardEnabled",    default = false },
        { type = "string", alias = "PriorityTrial1",                 default = "" },
        { type = "string", alias = "PriorityTrial2",                 default = "" },
        { type = "bool",   alias = "DreamRouteEnabled",              default = false },
        { type = "string", alias = "DreamRouteBiome1",               default = "G" },
        { type = "string", alias = "DreamRouteBiome2",               default = "I" },
        { type = "string", alias = "DreamRouteBiome3",               default = "N" },
        { type = "string", alias = "DreamRouteBiome4",               default = "P" },
        { type = "string", alias = "UnderworldTab", persist = false, hash = false, default = "F", maxLen = 32 },
        { type = "string", alias = "SurfaceTab",    persist = false, hash = false, default = "O", maxLen = 32 },
    }
end

return baseStorage
