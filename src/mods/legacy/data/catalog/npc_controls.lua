local deps = ...
local helpers = deps.helpers
local modeEntries = deps.modeEntries
local storageNodes = deps.storageNodes

local npcControls = {}

function npcControls.collectSpecs(biomes)
    local specs = {}

    for _, biome in ipairs(biomes) do
        helpers.appendBiomeSpecList(specs, biome.key, biome.npcs)
    end

    return specs
end

function npcControls.define(model, defaults, specs)
    local seenDepthAliases = {}
    for _, data in ipairs(specs or {}) do
        local entry = helpers.cloneData(data)
        local regionName = model.biomeMap[entry.biome] or entry.biome

        entry.region = regionName
        entry.minDefault = entry.min
        entry.maxDefault = entry.max
        entry.label = entry.label or entry.id
        entry.groupKey = entry.groupKey or entry.id
        entry.rangeMinAlias = entry.rangeMinAlias or ("PackedNPC" .. entry.id .. regionName .. "Min")
        entry.rangeMaxAlias = entry.rangeMaxAlias or ("PackedNPC" .. entry.id .. regionName .. "Max")
        entry.modeKey = entry.modeKey or ("ModeNPC" .. entry.id .. regionName)
        entry.modeValues = entry.modeValues or defaults.roomModeValues
        entry.modeDisplayValues = entry.modeDisplayValues or defaults.roomModeDisplayValues
        entry.defaultMode = entry.defaultMode or "default"
        modeEntries.prepare(model, defaults, entry, model.storageGroups.modeFields)
        storageNodes.appendDepthRange(model.storageGroups.npcDepth, entry, seenDepthAliases)

        table.insert(model.npcDefinitions, entry)
    end
end

function npcControls.buildLookups(model)
    for _, def in ipairs(model.npcDefinitions) do
        model.npcLookup[def.id] = model.npcLookup[def.id] or {}
        model.npcLookup[def.id][def.biome] = def
        if not model.npcGroups[def.groupKey] then
            model.npcGroups[def.groupKey] = {
                id = def.groupKey,
                label = def.label,
                actualNPCName = def.id,
                region = def.region,
                definitions = {},
                lookup = {},
            }
            table.insert(model.npcGroups.orderedIds, def.groupKey)
        end
        table.insert(model.npcGroups[def.groupKey].definitions, def)
        model.npcGroups[def.groupKey].lookup[def.biome] = def
    end

    for _, npcId in ipairs(model.npcGroups.orderedIds) do
        local group = model.npcGroups[npcId]
        table.sort(group.definitions, function(a, b)
            return a.biome < b.biome
        end)
    end
end

return npcControls
