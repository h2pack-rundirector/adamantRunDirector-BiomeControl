local deps = ...
local controlDefs = deps.controlDefs
local resolver = deps.resolver

local dreamRoute = {}

local DREAM_NATURAL_NEXT_BIOME = {
    F = "G",
    G = "H",
    H = "I",
    N = "O",
    N_SubRooms = "O",
    O = "P",
    P = "Q",
}

local function buildBiomeValues()
    local values = {}
    for _, biome in ipairs(resolver.biomes()) do
        values[#values + 1] = biome.key
    end
    return values
end

local function buildBiomeDisplayValues()
    local displayValues = {}
    for _, biome in ipairs(resolver.biomes()) do
        displayValues[biome.key] = biome.label
    end
    return displayValues
end

function dreamRoute.build()
    return controlDefs.dreamRoute("DreamRoute", {
        label = "Override Dream Run Biomes",
        values = buildBiomeValues(),
        displayValues = buildBiomeDisplayValues(),
        naturalNextBiome = DREAM_NATURAL_NEXT_BIOME,
        firstSlotDisallowed = {
            F = true,
            N = true,
        },
        defaults = { "G", "I", "N", "P" },
    })
end

return dreamRoute
