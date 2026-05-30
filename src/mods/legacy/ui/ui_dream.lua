local module = {}
local definitions
local catalog
local components

local function BindDraw()
    local DREAM_ROUTE_HEADING_COLOR = { 0.72, 0.80, 1.0, 1.0 }
    local biomeDisplayValues = {}
    local ROUTE_KEYS = {
        "DreamRouteBiome1",
        "DreamRouteBiome2",
        "DreamRouteBiome3",
        "DreamRouteBiome4",
    }
    local DREAM_ROUTE_ENABLED_OPTS = {
        label = "Override Dream Run Biomes",
    }
    local ROUTE_DROPDOWN_OPTS = {
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

    for biomeCode, biomeName in pairs(catalog.biomeMap) do
        biomeDisplayValues[biomeCode] = biomeName
    end

    local function IsKnownBiome(value)
        return biomeDisplayValues[value] ~= nil
    end

    local function IsValidAtSlot(value, slot, previous, used)
        if not IsKnownBiome(value) then return false end
        if slot == 1 and (value == "F" or value == "N") then return false end
        if used[value] then return false end
        if previous and definitions.dreamNaturalNextBiome[previous] == value then return false end
        return true
    end

    local function FirstValidValue(slot, previous, used)
        for _, value in ipairs(definitions.dreamBiomeOptions or {}) do
            if IsValidAtSlot(value, slot, previous, used) then
                return value
            end
        end
        return ""
    end

    local function NormalizeRoute(state)
        local previous = nil
        local used = {}

        for slot, key in ipairs(ROUTE_KEYS) do
            local field = state.get(key)
            local value = field:read()
            if not IsValidAtSlot(value, slot, previous, used) then
                value = FirstValidValue(slot, previous, used)
                field:write(value)
            end
            used[value] = true
            previous = value
        end
    end

    local function BuildSlotValues(slot, previous, used, current)
        local values = {}
        for _, value in ipairs(definitions.dreamBiomeOptions or {}) do
            if value == current or IsValidAtSlot(value, slot, previous, used) then
                values[#values + 1] = value
            end
        end
        return values
    end

    function module.draw(draw, state)
        NormalizeRoute(state)

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
            local opts = ROUTE_DROPDOWN_OPTS[slot]
            opts.values = BuildSlotValues(slot, previous, used, current)
            local changed = draw.widgets.dropdown(field, opts)

            if changed then
                NormalizeRoute(state)
                current = field:read()
            end

            used[current] = true
            previous = current
        end
    end
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    BindDraw()
    return module
end

return module
