local deps = ...
local module = {}
local definitions = deps.definitions
local catalog = deps.catalog
local components = deps.components

local DREAM_ROUTE_HEADING_COLOR = { 0.72, 0.80, 1.0, 1.0 }
local ROUTE_KEYS = {
    "DreamRouteBiome1",
    "DreamRouteBiome2",
    "DreamRouteBiome3",
    "DreamRouteBiome4",
}
local DREAM_ROUTE_ENABLED_OPTS = {
    label = "Override Dream Run Biomes",
}
local biomeDisplayValues = {}
local routeDropdownOpts = {
    {
        label = "Biome 1",
        displayValues = biomeDisplayValues,
        labelWidth = 80,
        controlWidth = 180,
    },
    {
        label = "Biome 2",
        displayValues = biomeDisplayValues,
        labelWidth = 80,
        controlWidth = 180,
    },
    {
        label = "Biome 3",
        displayValues = biomeDisplayValues,
        labelWidth = 80,
        controlWidth = 180,
    },
    {
        label = "Biome 4",
        displayValues = biomeDisplayValues,
        labelWidth = 80,
        controlWidth = 180,
    },
}

local function isKnownBiome(value)
    return biomeDisplayValues[value] ~= nil
end

local function isValidAtSlot(value, slot, previous, used)
    if not isKnownBiome(value) then return false end
    if slot == 1 and (value == "F" or value == "N") then return false end
    if used[value] then return false end
    if previous and definitions.dreamNaturalNextBiome[previous] == value then return false end
    return true
end

local function firstValidValue(slot, previous, used)
    for _, value in ipairs(definitions.dreamBiomeOptions or {}) do
        if isValidAtSlot(value, slot, previous, used) then
            return value
        end
    end
    return ""
end

local function normalizeRoute(state)
    local previous = nil
    local used = {}

    for slot, key in ipairs(ROUTE_KEYS) do
        local field = state.get(key)
        local value = field:read()
        if not isValidAtSlot(value, slot, previous, used) then
            value = firstValidValue(slot, previous, used)
            field:write(value)
        end
        used[value] = true
        previous = value
    end
end

local function buildSlotValues(slot, previous, used, current)
    local values = {}
    for _, value in ipairs(definitions.dreamBiomeOptions or {}) do
        if value == current or isValidAtSlot(value, slot, previous, used) then
            values[#values + 1] = value
        end
    end
    return values
end

function module.draw(draw, state)
    normalizeRoute(state)

    components.DrawSectionHeading(draw, "Dream Route", DREAM_ROUTE_HEADING_COLOR)
    draw.widgets.checkbox(state.get("DreamRouteEnabled"), DREAM_ROUTE_ENABLED_OPTS)

    if state.get("DreamRouteEnabled"):read() ~= true then
        return
    end

    local previous = nil
    local used = {}
    for slot, key in ipairs(ROUTE_KEYS) do
        local field = state.get(key)
        local current = field:read()
        local opts = routeDropdownOpts[slot]
        opts.values = buildSlotValues(slot, previous, used, current)
        local changed = draw.widgets.dropdown(field, opts)

        if changed then
            normalizeRoute(state)
            current = field:read()
        end

        used[current] = true
        previous = current
    end
end

for _, biome in ipairs(catalog.biomes.ordered or {}) do
    biomeDisplayValues[biome.key] = biome.label
end

return module
