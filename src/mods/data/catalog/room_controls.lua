local deps = ...
local helpers = deps.helpers
local modeEntries = deps.modeEntries
local storageNodes = deps.storageNodes

local roomControls = {}

local function getRoomLabel(entry, regionName)
    if entry.label then
        return entry.label
    end

    if entry.type == "Story" or entry.type == "Trial" or entry.type == "Fountain" or entry.type == "Shop" then
        return entry.type
    end

    return string.format("%s (%s)", entry.id, regionName)
end

local function getRoomKeyIdentifier(entry, regionName)
    if not entry.useRegionInKey then
        return entry.id
    end

    if entry.id == entry.type then
        return regionName
    end

    return entry.id .. regionName
end

function roomControls.collectSpecs(biomes)
    local specs = {}

    for _, biome in ipairs(biomes) do
        helpers.appendBiomeSpecList(specs, biome.key, biome.rooms)
    end

    return specs
end

function roomControls.define(model, defaults, specs)
    local seenDepthAliases = {}
    for _, data in ipairs(specs or {}) do
        local entry = helpers.cloneData(data)
        local regionName = model.biomeMap[entry.biome] or entry.biome
        local keyIdentifier = getRoomKeyIdentifier(entry, regionName)

        entry.region = regionName
        entry.minDefault = entry.min
        entry.maxDefault = entry.max
        entry.label = getRoomLabel(entry, regionName)
        entry.rangeMinAlias = entry.rangeMinAlias or ("Packed" .. entry.type .. keyIdentifier .. "Min")
        entry.rangeMaxAlias = entry.rangeMaxAlias or ("Packed" .. entry.type .. keyIdentifier .. "Max")
        entry.modeKey = entry.modeKey or ("Mode" .. entry.type .. keyIdentifier)
        modeEntries.prepare(model, defaults, entry, model.storageGroups.modeFields)
        storageNodes.appendDepthRange(model.storageGroups.roomDepth, entry, seenDepthAliases)

        table.insert(model.roomDefinitions, entry)
    end
end

function roomControls.buildLookups(model)
    for _, def in ipairs(model.roomDefinitions) do
        model.roomLookup[def.id] = model.roomLookup[def.id] or {}
        model.roomLookup[def.id][def.biome] = def

        model.biomeDefinitions[def.biome] = model.biomeDefinitions[def.biome] or {}
        model.biomeDefinitions[def.biome][def.type] = model.biomeDefinitions[def.biome][def.type] or {}
        table.insert(model.biomeDefinitions[def.biome][def.type], def)
    end
end

return roomControls
