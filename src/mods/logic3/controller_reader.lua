local reader = {}

local function binding(controller, key)
    return controller and controller.bindings and controller.bindings[key]
end

function reader.readMode(store, controller)
    local mode = binding(controller, "mode")
    if not mode then
        return "default"
    end

    local encoded = store.read(mode.alias)
    encoded = math.floor(tonumber(encoded) or 0)
    return mode.values[encoded + 1] or mode.default
end

function reader.readRange(store, controller)
    local range = binding(controller, "range")
    if not range then
        return 0, 99
    end

    local minValue = store.read(range.minAlias)
    local maxValue = store.read(range.maxAlias)
    return minValue or range.min, maxValue or range.max
end

function reader.readValue(store, controller)
    local value = binding(controller, "value")
    if not value then
        return nil
    end
    return store.read(value.alias)
end

function reader.readPacked(store, controller)
    local packed = binding(controller, "packed")
    if not packed then
        return 0
    end
    return store.read(packed.alias) or 0
end

function reader.getPackedOptions(controller)
    local packed = binding(controller, "packed")
    return packed and packed.options or {}
end

return reader
