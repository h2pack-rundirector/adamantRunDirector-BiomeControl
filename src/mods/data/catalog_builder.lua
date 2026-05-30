local catalogBuilder = {}

local function cloneData(data)
    local copy = {}
    for key, value in pairs(data or {}) do
        copy[key] = value
    end
    return copy
end

local function appendSetting(target, entry)
    if entry and entry.setting then
        target[#target + 1] = entry.setting
    end
end

local function applyDefaultSettingLabel(entry, label)
    if entry and entry.setting and entry.setting.label == nil then
        entry.setting.label = label
    end
end

local function gather(...)
    local items = {}
    for index = 1, select("#", ...) do
        for _, item in ipairs(select(index, ...) or {}) do
            items[#items + 1] = item
        end
    end
    return items
end

function catalogBuilder.rooms(specs)
    local roomLookup = {}
    local roomOrder = {}
    local minibossLookup = {}
    local minibossOrder = {}
    local settings = {}

    for _, spec in ipairs(specs or {}) do
        local entry = cloneData(spec)
        applyDefaultSettingLabel(entry, entry.label)
        appendSetting(settings, entry)
        if entry.type == "MiniBoss" then
            minibossLookup[entry.id] = entry
            minibossOrder[#minibossOrder + 1] = entry
        else
            roomLookup[entry.id] = entry
            roomOrder[#roomOrder + 1] = entry
        end
    end

    return {
        rooms = roomLookup,
        roomOrder = roomOrder,
        minibosses = minibossLookup,
        minibossOrder = minibossOrder,
        settings = settings,
    }
end

function catalogBuilder.npcs(specs)
    local lookup = {}
    local groups = { orderedIds = {} }
    local ordered = {}
    local settings = {}

    for _, spec in ipairs(specs or {}) do
        local entry = cloneData(spec)
        applyDefaultSettingLabel(entry, entry.biomeLabel or entry.label)
        appendSetting(settings, entry)
        lookup[entry.id] = entry
        ordered[#ordered + 1] = entry

        if not groups[entry.groupKey] then
            groups[entry.groupKey] = {
                id = entry.groupKey,
                label = entry.label,
                actualNPCName = entry.id,
                definitions = {},
                lookup = {},
            }
            groups.orderedIds[#groups.orderedIds + 1] = entry.groupKey
        end
        groups[entry.groupKey].definitions[#groups[entry.groupKey].definitions + 1] = entry
        groups[entry.groupKey].lookup[entry.biome] = entry
    end

    return {
        ordered = ordered,
        lookup = lookup,
        groups = groups,
        settings = settings,
    }
end

function catalogBuilder.controls(specs)
    local lookup = {}
    local ordered = {}
    local settings = {}

    for _, spec in ipairs(specs or {}) do
        local setting = spec.setting or spec
        local entry = spec.setting and cloneData(spec) or {}
        entry.key = setting.name
        entry.setting = setting
        lookup[entry.key] = entry
        ordered[#ordered + 1] = entry
        settings[#settings + 1] = setting
    end

    return {
        ordered = ordered,
        lookup = lookup,
        settings = settings,
    }
end

function catalogBuilder.biomeBundle(definition, parts)
    local rooms = parts.rooms
    local npcs = parts.npcs
    local controls = parts.controls

    local biome = {
        key = definition.key,
        label = definition.label,
        region = definition.region,
        logic = definition.logic,
        ui = definition.ui,
        definition = definition,
        rooms = rooms.rooms,
        roomOrder = rooms.roomOrder,
        minibosses = rooms.minibosses,
        minibossOrder = rooms.minibossOrder,
        npcs = npcs.lookup,
        npcOrder = npcs.ordered,
        controls = controls and controls.lookup or {},
        controlOrder = controls and controls.ordered or {},
    }

    return {
        definition = definition,
        biome = biome,
        npcGroups = npcs.groups,
        settings = gather(
            rooms.settings,
            npcs.settings,
            controls and controls.settings
        ),
    }
end

return catalogBuilder
