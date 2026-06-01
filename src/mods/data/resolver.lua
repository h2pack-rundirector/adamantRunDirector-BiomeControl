local resolverModule = {}

local EMPTY_LIST = {}

local function append(target, value)
    target[#target + 1] = value
end

local function buildBiomeIndexes(catalog)
    local biomes = catalog.biomes or {}
    local ordered = {}
    local byKey = {}
    local byRegion = {}
    local uiModules = {}
    local logicModules = {}

    for _, biome in ipairs(biomes.ordered or {}) do
        local summary = {
            key = biome.key,
            label = biome.label,
            region = biome.region,
        }
        append(ordered, summary)
        byKey[biome.key] = summary
        if biome.region then
            byRegion[biome.region] = byRegion[biome.region] or {}
            append(byRegion[biome.region], summary)
        end
        if biome.ui then
            append(uiModules, {
                biomeKey = biome.key,
                path = biome.ui,
            })
        end
        if biome.logic then
            append(logicModules, {
                biomeKey = biome.key,
                path = biome.logic,
            })
        end
    end

    return ordered, byKey, byRegion, uiModules, logicModules
end

local function buildNpcIndexes(catalog)
    local groups = catalog.npcs or {}
    local orderedGroups = {}
    local groupById = {}
    local groupsByRegion = {}
    local groupByIdByRegion = {}
    local actualNpcLookup = {}
    local regionByBiome = {}

    for _, biome in ipairs(catalog.biomes.ordered or {}) do
        regionByBiome[biome.key] = biome.region
    end

    for _, groupKey in ipairs(groups.orderedIds or {}) do
        local group = groups[groupKey]
        if group then
            local allEntries = group.definitions or EMPTY_LIST
            local normalizedGroup = {
                id = group.id,
                label = group.label,
                actualNPCName = group.actualNPCName,
                entries = allEntries,
            }
            append(orderedGroups, normalizedGroup)
            groupById[group.id] = normalizedGroup

            for _, entry in ipairs(allEntries) do
                local actualName = group.actualNPCName
                if actualName then
                    actualNpcLookup[actualName] = actualNpcLookup[actualName] or {}
                    actualNpcLookup[actualName][entry.biome] = entry
                end

                local region = regionByBiome[entry.biome]
                if region then
                    groupsByRegion[region] = groupsByRegion[region] or {}
                    groupByIdByRegion[region] = groupByIdByRegion[region] or {}
                    local regionGroup = groupByIdByRegion[region][groupKey]
                    if not regionGroup then
                        regionGroup = {
                            id = group.id,
                            label = group.label,
                            actualNPCName = group.actualNPCName,
                            entries = {},
                        }
                        groupByIdByRegion[region][groupKey] = regionGroup
                        append(groupsByRegion[region], regionGroup)
                    end
                    append(regionGroup.entries, entry)
                end
            end
        end
    end

    return orderedGroups, groupById, groupsByRegion, groupByIdByRegion, actualNpcLookup
end

local function controlNameOf(entry)
    return entry and entry.controlName or nil
end

function resolverModule.create(catalog)
    local resolver = {}
    local biomes, biomeByKey, biomeByRegion, uiModules, logicModules = buildBiomeIndexes(catalog)
    local npcGroups, npcGroupById, npcGroupsByRegion, npcGroupByIdByRegion, actualNpcLookup = buildNpcIndexes(catalog)

    local function rawBiome(biomeKey)
        return catalog.biomes and catalog.biomes[biomeKey] or nil
    end

    function resolver.biome(biomeKey)
        return biomeByKey[biomeKey]
    end

    function resolver.biomes(region)
        if region == nil then
            return biomes
        end
        return biomeByRegion[region] or EMPTY_LIST
    end

    local function roomEntry(biomeKey, roomKey)
        local biome = rawBiome(biomeKey)
        return biome and biome.rooms and biome.rooms[roomKey] or nil
    end

    function resolver.room(biomeKey, roomKey)
        return controlNameOf(roomEntry(biomeKey, roomKey))
    end

    local function minibossEntry(biomeKey, minibossKey)
        local biome = rawBiome(biomeKey)
        return biome and biome.minibosses and biome.minibosses[minibossKey] or nil
    end

    function resolver.miniboss(biomeKey, minibossKey)
        return controlNameOf(minibossEntry(biomeKey, minibossKey))
    end

    function resolver.roomInfo(biomeKey, roomKey)
        return roomEntry(biomeKey, roomKey)
    end

    function resolver.minibossInfo(biomeKey, minibossKey)
        return minibossEntry(biomeKey, minibossKey)
    end

    local function controlEntry(biomeKey, controlKey)
        local biome = rawBiome(biomeKey)
        return biome and biome.controls and biome.controls[controlKey] or nil
    end

    function resolver.control(biomeKey, controlKey)
        return controlNameOf(controlEntry(biomeKey, controlKey))
    end

    function resolver.controls(biomeKey)
        local biome = rawBiome(biomeKey)
        return biome and biome.controlOrder or EMPTY_LIST
    end

    function resolver.npcGroup(groupKey, region)
        if region ~= nil then
            local regionGroups = npcGroupByIdByRegion[region]
            return regionGroups and regionGroups[groupKey] or nil
        end
        return npcGroupById[groupKey]
    end

    function resolver.npcGroups(region)
        if region == nil then
            return npcGroups
        end
        return npcGroupsByRegion[region] or EMPTY_LIST
    end

    function resolver.npcInfo(groupKey, biomeKey)
        local groups = catalog.npcs or {}
        local group = groups[groupKey]
        return group and group.lookup and group.lookup[biomeKey] or nil
    end

    function resolver.npc(groupKey, biomeKey)
        return controlNameOf(resolver.npcInfo(groupKey, biomeKey))
    end

    function resolver.npcInfoByActualName(actualName, biomeKey)
        local byBiome = actualNpcLookup[actualName]
        return byBiome and byBiome[biomeKey] or nil
    end

    function resolver.biomeUiModules()
        return uiModules
    end

    function resolver.biomeLogicModules()
        return logicModules
    end

    return resolver
end

return resolverModule
