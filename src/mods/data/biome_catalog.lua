local catalog = {}

local function cloneData(data)
    local copy = {}
    for key, value in pairs(data or {}) do
        copy[key] = value
    end
    return copy
end

local function gatherControlDeclarations(declarations)
    local controls = {}

    for _, control in ipairs(declarations or {}) do
        controls[#controls + 1] = control
    end

    local keys = {}
    for key in pairs(declarations or {}) do
        if type(key) ~= "number" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        controls[#controls + 1] = declarations[key]
    end

    return controls
end

local function buildControlLookup(declarations)
    local lookup = {}

    for _, control in ipairs(declarations or {}) do
        if control and control.name then
            lookup[control.name] = true
        end
    end

    for key, control in pairs(declarations or {}) do
        if type(key) ~= "number" then
            lookup[key] = true
        end
        if control and control.name then
            lookup[control.name] = true
        end
    end

    return lookup
end

local function validateControlRef(controlLookup, context, entry)
    local controlName = entry and entry.controlName or nil
    if controlName ~= nil and not controlLookup[controlName] then
        error(string.format("%s references undeclared control '%s'", context, tostring(controlName)), 0)
    end
end

local function validateControlRefs(definition, parts)
    local controlLookup = buildControlLookup(parts.controlDeclarations)
    local rooms = parts.rooms
    local npcs = parts.npcs
    local controlRefs = parts.controlRefs
    local biomeKey = definition and definition.key or "?"

    for _, entry in ipairs(rooms and rooms.roomOrder or {}) do
        validateControlRef(controlLookup, "biome " .. tostring(biomeKey) .. " room " .. tostring(entry.id), entry)
    end
    for _, entry in ipairs(rooms and rooms.minibossOrder or {}) do
        validateControlRef(controlLookup, "biome " .. tostring(biomeKey) .. " miniboss " .. tostring(entry.id), entry)
    end
    for _, entry in ipairs(npcs and npcs.ordered or {}) do
        validateControlRef(controlLookup, "biome " .. tostring(biomeKey) .. " npc " .. tostring(entry.id), entry)
    end
    for _, entry in ipairs(controlRefs and controlRefs.ordered or {}) do
        validateControlRef(controlLookup, "biome " .. tostring(biomeKey) .. " control ref " .. tostring(entry.key), entry)
    end
end

function catalog.room(biome)
    return {
        story = function(id, opts)
            opts = opts or {}
            local entry = cloneData(opts)
            entry.id = id
            entry.type = "Story"
            entry.biome = biome.key
            entry.biomeLabel = biome.label
            entry.label = opts.label or "Story"
            return entry
        end,
        trial = function(opts)
            opts = cloneData(opts)
            opts.id = opts.id or "Trial"
            opts.type = "Trial"
            opts.biome = biome.key
            opts.biomeLabel = biome.label
            opts.label = opts.label or "Trial"
            return opts
        end,
        fountain = function(opts)
            opts = cloneData(opts)
            opts.id = opts.id or "Fountain"
            opts.type = "Fountain"
            opts.biome = biome.key
            opts.biomeLabel = biome.label
            opts.label = opts.label or "Fountain"
            return opts
        end,
        shop = function(opts)
            opts = cloneData(opts)
            opts.id = opts.id or "Shop"
            opts.type = "Shop"
            opts.biome = biome.key
            opts.biomeLabel = biome.label
            opts.label = opts.label or "Shop"
            return opts
        end,
        minibossDepth = function(id, opts)
            opts = opts or {}
            local entry = cloneData(opts)
            entry.id = id
            entry.type = "MiniBoss"
            entry.biome = biome.key
            entry.biomeLabel = biome.label
            entry.label = opts.label or string.format("%s (%s)", id, biome.label)
            return entry
        end,
    }
end

function catalog.npc(biome)
    return function(id, opts)
        opts = opts or {}
        local entry = cloneData(opts)
        entry.id = id
        entry.biome = biome.key
        entry.biomeLabel = biome.label
        entry.label = opts.label or id
        entry.groupKey = opts.groupKey or id
        return entry
    end
end

function catalog.rooms(specs)
    local roomLookup = {}
    local roomOrder = {}
    local minibossLookup = {}
    local minibossOrder = {}

    for _, spec in ipairs(specs or {}) do
        local entry = cloneData(spec)
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
    }
end

function catalog.npcs(specs)
    local lookup = {}
    local groups = { orderedIds = {} }
    local ordered = {}

    for _, spec in ipairs(specs or {}) do
        local entry = cloneData(spec)
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
    }
end

function catalog.controlRefs(specs)
    local lookup = {}
    local ordered = {}

    for _, spec in ipairs(specs or {}) do
        local entry = type(spec) == "table" and cloneData(spec) or {
            controlName = spec,
        }
        entry.key = entry.key or entry.controlName
        lookup[entry.key] = entry
        ordered[#ordered + 1] = entry
    end

    return {
        ordered = ordered,
        lookup = lookup,
    }
end

function catalog.biome(definition, parts)
    validateControlRefs(definition, parts)

    local rooms = parts.rooms
    local npcs = parts.npcs
    local controlRefs = parts.controlRefs

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
        controls = controlRefs and controlRefs.lookup or {},
        controlOrder = controlRefs and controlRefs.ordered or {},
    }

    return {
        definition = definition,
        biome = biome,
        npcGroups = npcs.groups,
        controls = gatherControlDeclarations(parts.controlDeclarations),
    }
end

return catalog
