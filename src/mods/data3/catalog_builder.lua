local catalogBuilder = {}

local function cloneData(data)
    local copy = {}
    for key, value in pairs(data or {}) do
        copy[key] = value
    end
    return copy
end

local function appendController(target, entry)
    if entry and entry.controller then
        target[#target + 1] = entry.controller
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
    local controllers = {}

    for _, spec in ipairs(specs or {}) do
        local entry = cloneData(spec)
        appendController(controllers, entry)
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
        controllers = controllers,
    }
end

function catalogBuilder.npcs(specs)
    local lookup = {}
    local groups = { orderedIds = {} }
    local ordered = {}
    local controllers = {}

    for _, spec in ipairs(specs or {}) do
        local entry = cloneData(spec)
        appendController(controllers, entry)
        lookup[entry.id] = entry
        ordered[#ordered + 1] = entry

        if not groups[entry.groupKey] then
            groups[entry.groupKey] = {
                id = entry.groupKey,
                label = entry.label,
                actualNPCName = entry.id,
                region = entry.region,
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
        controllers = controllers,
    }
end

function catalogBuilder.controls(specs)
    local lookup = {}
    local ordered = {}
    local controllers = {}

    for _, spec in ipairs(specs or {}) do
        local entry = cloneData(spec)
        local controller = entry.controller or entry
        entry.controller = controller
        entry.key = controller.key
        lookup[entry.key] = entry
        ordered[#ordered + 1] = entry
        controllers[#controllers + 1] = controller
    end

    return {
        ordered = ordered,
        lookup = lookup,
        controllers = controllers,
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
        ui3 = definition.ui3,
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
        controllers = gather(
            rooms.controllers,
            npcs.controllers,
            controls and controls.controllers
        ),
    }
end

return catalogBuilder
