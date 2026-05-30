local modeEntries = {}

local function resolveModeEntry(model, entryOrKey)
    if type(entryOrKey) == "table" then
        return entryOrKey
    end
    return model.modeEntryLookup[entryOrKey]
end

function modeEntries.prepare(model, defaults, entry, storageTarget)
    entry.modeValues = entry.modeValues or defaults.roomModeValues
    entry.modeDisplayValues = entry.modeDisplayValues or defaults.roomModeDisplayValues
    entry.defaultMode = entry.defaultMode or entry.modeValues[1] or "default"
    entry.modeValueLookup = {}
    for index, value in ipairs(entry.modeValues) do
        entry.modeValueLookup[value] = index - 1
    end
    model.modeEntryLookup[entry.modeKey] = entry
    local storageNode = {
        type = "int",
        alias = entry.modeKey,
        default = entry.modeValueLookup[entry.defaultMode] or 0,
        min = 0,
        max = math.max(#entry.modeValues - 1, 0),
    }
    table.insert(model.modeStorageFields, storageNode)
    if storageTarget then
        storageTarget[#storageTarget + 1] = storageNode
    end
end

function modeEntries.attachAccessors(model)
    function model.GetModeValue(readFn, entryOrKey)
        local entry = resolveModeEntry(model, entryOrKey)
        if not entry then return "default" end

        local encoded = readFn(entry.modeKey)
        encoded = math.floor(tonumber(encoded) or 0)
        return entry.modeValues[encoded + 1] or entry.defaultMode
    end

    function model.GetModeDisplay(entryOrKey, value)
        local entry = resolveModeEntry(model, entryOrKey)
        if not entry then
            return tostring(value)
        end
        return entry.modeDisplayValues[value] or tostring(value)
    end
end

return modeEntries
