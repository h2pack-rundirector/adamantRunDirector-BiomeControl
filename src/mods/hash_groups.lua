local hashGroups = {}
local catalog

local function getNewRoomDef(id, biome)
    local biomeDef = catalog.biomes and catalog.biomes[biome]
    if not biomeDef then
        return nil
    end
    return (biomeDef.rooms and biomeDef.rooms[id])
        or (biomeDef.minibosses and biomeDef.minibosses[id])
        or nil
end

local function getRoomDef(id, biome)
    if catalog.roomLookup then
        return catalog.roomLookup[id] and catalog.roomLookup[id][biome] or nil
    end
    return getNewRoomDef(id, biome)
end

local function getNewNpcDef(id, biome)
    local npcs = catalog.npcs
    if not npcs then
        return nil
    end

    for _, groupKey in ipairs(npcs.orderedIds or {}) do
        local group = npcs[groupKey]
        if group and group.actualNPCName == id then
            local def = group.lookup and group.lookup[biome] or nil
            if def then
                return def
            end
        end
    end
end

local function getNpcDef(id, biome)
    if catalog.npcLookup then
        return catalog.npcLookup[id] and catalog.npcLookup[id][biome] or nil
    end
    return getNewNpcDef(id, biome)
end

local function getRangedControlAliases(def)
    if not def then
        return nil
    end

    local bindings = def.controller and def.controller.bindings
    if bindings then
        local aliases = {}
        if bindings.mode then
            aliases[#aliases + 1] = bindings.mode.alias
        end
        if bindings.range then
            aliases[#aliases + 1] = bindings.range.minAlias
            aliases[#aliases + 1] = bindings.range.maxAlias
        end
        return aliases
    end

    return {
        def.modeKey,
        def.rangeMinAlias,
        def.rangeMaxAlias,
    }
end

function hashGroups.buildHashGroupPlan()
    return {
        {
            keyPrefix = "global",
            items = {
                {
                    "OnlyAllowForcedEncounters",
                    "IgnoreMaxDepth",
                    "NPCSpacing",
                    "PrioritizeSpecificRewardEnabled",
                    "PrioritizeTrialRewardEnabled",
                },
            },
        },
        {
            keyPrefix = "F",
            items = {
                getRangedControlAliases(getRoomDef("Arachne", "F")),
                getRangedControlAliases(getRoomDef("Trial", "F")),
                getRangedControlAliases(getRoomDef("Fountain", "F")),
                getRangedControlAliases(getRoomDef("Shop", "F")),
                getRangedControlAliases(getRoomDef("Treant", "F")),
                getRangedControlAliases(getRoomDef("FogEmitter", "F")),
                getRangedControlAliases(getRoomDef("Assassin", "F")),
                getRangedControlAliases(getNpcDef("Artemis", "F")),
                getRangedControlAliases(getNpcDef("Nemesis", "F")),
            },
        },
        {
            keyPrefix = "G",
            items = {
                getRangedControlAliases(getRoomDef("Narcissus", "G")),
                getRangedControlAliases(getRoomDef("Trial", "G")),
                getRangedControlAliases(getRoomDef("Fountain", "G")),
                getRangedControlAliases(getRoomDef("Shop", "G")),
                getRangedControlAliases(getRoomDef("WaterUnit", "G")),
                getRangedControlAliases(getRoomDef("Crawler", "G")),
                getRangedControlAliases(getRoomDef("Jellyfish", "G")),
                getRangedControlAliases(getNpcDef("Artemis", "G")),
                getRangedControlAliases(getNpcDef("Nemesis", "G")),
            },
        },
        {
            keyPrefix = "H",
            items = {
                getRangedControlAliases(getRoomDef("Vampire", "H")),
                getRangedControlAliases(getRoomDef("Lamia", "H")),
                getRangedControlAliases(getNpcDef("Nemesis", "H")),
                {
                    "PreventEchoScam",
                    "ForceTwoRewardFieldsOpeners",
                },
            },
        },
        {
            keyPrefix = "I",
            items = {
                getRangedControlAliases(getRoomDef("RatCatcher", "I")),
                getRangedControlAliases(getRoomDef("GoldElemental", "I")),
                {
                    "PackedNPCNemesisTartarusMin",
                    "PackedNPCNemesisTartarusMax",
                },
            },
        },
        {
            keyPrefix = "N",
            items = {
                "EphyraStoryMode",
                "EphyraMiniBossMode",
                getRangedControlAliases(getNpcDef("Artemis", "N")),
                getRangedControlAliases(getNpcDef("Heracles", "N")),
            },
        },
        {
            keyPrefix = "O",
            items = {
                getRangedControlAliases(getRoomDef("Circe", "O")),
                getRangedControlAliases(getRoomDef("Trial", "O")),
                getRangedControlAliases(getRoomDef("Fountain", "O")),
                getRangedControlAliases(getRoomDef("Shop", "O")),
                {
                    "ThessalyMiniBossMode",
                    "PackedForcedThessalyMiniBossMin",
                    "PackedForcedThessalyMiniBossMax",
                },
                getRangedControlAliases(getNpcDef("Heracles", "O")),
                getRangedControlAliases(getNpcDef("Icarus", "O")),
            },
        },
        {
            keyPrefix = "P",
            items = {
                getRangedControlAliases(getRoomDef("Dionysus", "P")),
                getRangedControlAliases(getRoomDef("Fountain", "P")),
                getRangedControlAliases(getRoomDef("Shop", "P")),
                getRangedControlAliases(getRoomDef("Talos", "P")),
                getRangedControlAliases(getRoomDef("Dragon", "P")),
                getRangedControlAliases(getNpcDef("Heracles", "P")),
                getRangedControlAliases(getNpcDef("Athena", "P")),
                getRangedControlAliases(getNpcDef("Icarus", "P")),
            },
        },
    }
end

function hashGroups.bind(data)
    catalog = data.catalog
    return hashGroups
end

return hashGroups
