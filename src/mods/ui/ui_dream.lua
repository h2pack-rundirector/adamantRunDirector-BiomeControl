local module = {}
local definitions
local catalog
local components

local function BindDraw()
    local biomeDisplayValues = {}
    local ROUTE_KEYS = {
        "DreamRouteBiome1",
        "DreamRouteBiome2",
        "DreamRouteBiome3",
        "DreamRouteBiome4",
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

    local function NormalizeRoute(session)
        local previous = nil
        local used = {}

        for slot, key in ipairs(ROUTE_KEYS) do
            local value = session.view[key]
            if not IsValidAtSlot(value, slot, previous, used) then
                value = FirstValidValue(slot, previous, used)
                session.write(key, value)
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

    function module.draw(ctx)
        local session = ctx.session
        NormalizeRoute(session)

        components.DrawSectionHeading(ctx, "Dream Route", { 0.72, 0.80, 1.0, 1.0 })
        ctx.widgets.checkbox("DreamRouteEnabled", {
            label = "Override Dream Run Biomes",
        })

        if session.view.DreamRouteEnabled ~= true then
            return
        end

        local previous = nil
        local used = {}
        for slot, key in ipairs(ROUTE_KEYS) do
            local current = session.view[key]
            local changed = ctx.widgets.dropdown(key, {
                label = "Biome " .. slot,
                values = BuildSlotValues(slot, previous, used, current),
                displayValues = biomeDisplayValues,
                labelWidth = 80,
                controlWidth = 180,
            })

            if changed then
                NormalizeRoute(session)
                current = session.view[key]
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
