local deps = ...
local helpers = deps.helpers
local modeEntries = deps.modeEntries
local storageNodes = deps.storageNodes

local extensionControls = {}

function extensionControls.prepareBiome(model, biome)
    model.biomeLookup[biome.key] = biome
    model.biomeMap[biome.key] = biome.label
    model.biomeTabs[#model.biomeTabs + 1] = {
        key = biome.key,
        label = biome.label,
        region = biome.region,
    }
    model.biomeRooms[biome.key] = model.biomeRooms[biome.key] or {}
    model.biomeSpecials[biome.key] = model.biomeSpecials[biome.key] or {}
    model.biomeRewards[biome.key] = model.biomeRewards[biome.key] or {}

    local controls = biome.controls or {}
    helpers.appendClonedList(model.stateFields, controls.stateFields)
    helpers.appendClonedList(model.rangeFields, controls.rangeFields)
    helpers.appendClonedList(model.biomeRooms[biome.key], controls.rooms)
    helpers.appendClonedList(model.biomeRewards[biome.key], controls.rewards)
    helpers.appendClonedList(model.biomeSpecials[biome.key], controls.specials)
end

function extensionControls.preparePackedRewards(model, biomes)
    local packedRewardFields = {}
    local orderedAliases = {}

    for _, biome in ipairs(biomes or {}) do
        local rewards = model.biomeRewards and model.biomeRewards[biome.key] or nil
        for _, reward in ipairs(rewards or {}) do
            if reward.kind == "packedCheckboxes" and type(reward.alias) == "string" and reward.alias ~= "" then
                if packedRewardFields[reward.alias] == nil then
                    orderedAliases[#orderedAliases + 1] = reward.alias
                end
                packedRewardFields[reward.alias] = reward
            end
        end
    end

    local ordered = {}
    for _, alias in ipairs(orderedAliases) do
        local reward = packedRewardFields[alias]
        ordered[#ordered + 1] = reward
        storageNodes.appendPackedReward(model.storageGroups.packedRewards, reward)
    end

    model.packedRewardFields = packedRewardFields
    model.packedRewardFieldsOrdered = ordered
end

function extensionControls.prepareStateFields(model)
    for _, field in ipairs(model.stateFields or {}) do
        storageNodes.appendStateField(model.storageGroups.stateFields, field)
    end
end

function extensionControls.prepareRangeFields(model)
    local lookup = {}

    for _, field in ipairs(model.rangeFields or {}) do
        lookup[field.rangeMinAlias] = field
        lookup[field.rangeMaxAlias] = field
        storageNodes.appendRangeField(model.storageGroups.rangeFields, field)
    end

    model.rangeFieldLookup = lookup
end

function extensionControls.prepareModeFields(model, defaults, biomes)
    for _, biome in ipairs(biomes or {}) do
        local entries = model.biomeRooms[biome.key] or {}
        for _, entry in ipairs(entries) do
            if entry.kind == "modeField" then
                entry.modeKey = entry.modeKey or entry.alias or entry.label
                modeEntries.prepare(model, defaults, entry, model.storageGroups.modeFields)
            end
        end
    end
end

return extensionControls
