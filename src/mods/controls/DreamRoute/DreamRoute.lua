local deps = ...

local shared = deps.shared

local DreamRoute = {}

local SLOT_KEYS = {
    "Biome1",
    "Biome2",
    "Biome3",
    "Biome4",
}

local function isKnownBiome(instance, value)
    return instance.knownValues[value] == true
end

local function isNaturalNext(instance, current, nextValue)
    return current ~= nil and instance.naturalNextBiome[current] == nextValue
end

local function isValidAtSlot(instance, value, slot, previous, used)
    if not isKnownBiome(instance, value) then return false end
    if slot == 1 and instance.firstSlotDisallowed[value] == true then return false end
    if used[value] then return false end
    if isNaturalNext(instance, previous, value) then return false end
    return true
end

local function firstValidValue(instance, slot, previous, used)
    for _, value in ipairs(instance.values or {}) do
        if isValidAtSlot(instance, value, slot, previous, used) then
            return value
        end
    end
    return ""
end

local function readRoute(fields)
    local route = {}
    for slot, key in ipairs(SLOT_KEYS) do
        route[slot] = fields[key]:read()
    end
    return route
end

local function isValidRoute(instance, route)
    local previous = nil
    local used = {}

    for slot, value in ipairs(route or {}) do
        if not isValidAtSlot(instance, value, slot, previous, used) then
            return false
        end
        used[value] = true
        previous = value
    end

    return #(route or {}) == #SLOT_KEYS
end

local function refreshSlotVisibility(instance, slot, previous, used, current)
    local visibleValues = instance.slotVisibleValues[slot]
    for _, value in ipairs(instance.values or {}) do
        visibleValues[value] = value == current or isValidAtSlot(instance, value, slot, previous, used)
    end
end

function DreamRoute.prepare(instance)
    instance.values = shared.cloneList(instance.values)
    instance.displayValues = shared.cloneMap(instance.displayValues)
    instance.naturalNextBiome = shared.cloneMap(instance.naturalNextBiome)
    instance.firstSlotDisallowed = shared.cloneMap(instance.firstSlotDisallowed)
    instance.defaults = instance.defaults or {}
    instance.knownValues = {}
    instance.slotVisibleValues = {}
    instance.slotOpts = {}
    instance.enabledOpts = {
        label = instance.label or "Override Dream Run Biomes",
        tooltip = instance.helpText,
    }

    for _, value in ipairs(instance.values or {}) do
        instance.knownValues[value] = true
    end

    for slot = 1, #SLOT_KEYS do
        local visibleValues = {}
        instance.slotVisibleValues[slot] = visibleValues
        instance.slotOpts[slot] = {
            label = "Biome " .. tostring(slot),
            values = instance.values,
            displayValues = instance.displayValues,
            visibleValues = visibleValues,
            labelWidth = instance.labelWidth or 80,
            controlWidth = instance.controlWidth or 180,
        }
    end

    return instance
end

function DreamRoute.storage(instance)
    return {
        {
            key = "Enabled",
            type = "bool",
            default = instance.defaultEnabled == true,
        },
        {
            key = "Biome1",
            type = "string",
            default = instance.defaults[1] or "G",
            maxLen = 32,
        },
        {
            key = "Biome2",
            type = "string",
            default = instance.defaults[2] or "I",
            maxLen = 32,
        },
        {
            key = "Biome3",
            type = "string",
            default = instance.defaults[3] or "N",
            maxLen = 32,
        },
        {
            key = "Biome4",
            type = "string",
            default = instance.defaults[4] or "P",
            maxLen = 32,
        },
    }
end

function DreamRoute.createRuntime(fields, instance)
    local control = {}

    function control.isEnabled()
        return fields.Enabled:read() == true
    end

    function control.route()
        if fields.Enabled:read() ~= true then
            return nil
        end

        local route = readRoute(fields)
        if not isValidRoute(instance, route) then
            return nil
        end
        return route
    end

    function control.biomeAt(_, index)
        index = math.floor(tonumber(index) or 0)
        if fields.Enabled:read() ~= true then
            return nil
        end
        local route = readRoute(fields)
        if not isValidRoute(instance, route) then
            return nil
        end
        return route and route[index] or nil
    end

    function control.isNaturalNext(_, current, nextValue)
        return isNaturalNext(instance, current, nextValue)
    end

    return control
end

function DreamRoute.createUi(fields, instance)
    local control = DreamRoute.createRuntime(fields, instance)

    function control.field(_, key)
        return fields[key]
    end

    function control.writeEnabled(_, value)
        return fields.Enabled:write(value == true)
    end

    function control.writeBiome(_, slot, value)
        slot = math.floor(tonumber(slot) or 0)
        local key = SLOT_KEYS[slot]
        if key == nil then
            return false
        end
        return fields[key]:write(value)
    end

    return control
end

local function normalizeUiRoute(control, instance)
    local previous = nil
    local used = {}

    for slot, key in ipairs(SLOT_KEYS) do
        local field = control:field(key)
        local value = field:read()
        if not isValidAtSlot(instance, value, slot, previous, used) then
            value = firstValidValue(instance, slot, previous, used)
            field:write(value)
        end
        used[value] = true
        previous = value
    end
end

local function refreshUiVisibility(control, instance)
    local previous = nil
    local used = {}

    for slot, key in ipairs(SLOT_KEYS) do
        local current = control:field(key):read()
        refreshSlotVisibility(instance, slot, previous, used, current)
        used[current] = true
        previous = current
    end
end

function DreamRoute.draw(draw, control, instance)
    normalizeUiRoute(control, instance)
    refreshUiVisibility(control, instance)

    draw.widgets.checkbox(control:field("Enabled"), instance.enabledOpts)
    if not control:isEnabled() then
        return
    end

    for slot, key in ipairs(SLOT_KEYS) do
        local changed = draw.widgets.dropdown(control:field(key), instance.slotOpts[slot])
        if changed then
            normalizeUiRoute(control, instance)
            refreshUiVisibility(control, instance)
        end
    end
end

return DreamRoute
