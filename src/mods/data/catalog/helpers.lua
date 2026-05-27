local helpers = {}

function helpers.cloneData(data)
    local copy = {}
    for key, value in pairs(data) do
        copy[key] = value
    end
    return copy
end

function helpers.appendClonedList(target, values)
    for _, value in ipairs(values or {}) do
        target[#target + 1] = helpers.cloneData(value)
    end
end

function helpers.appendBiomeSpecList(target, biomeKey, values)
    for _, value in ipairs(values or {}) do
        local entry = helpers.cloneData(value)
        entry.biome = entry.biome or biomeKey
        target[#target + 1] = entry
    end
end

return helpers
