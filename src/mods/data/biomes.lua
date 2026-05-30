local biomes = {}

local BIOME_IMPORTS = {
    "mods/data/biomes/f_erebus.lua",
    "mods/data/biomes/g_oceanus.lua",
    "mods/data/biomes/h_fields.lua",
    "mods/data/biomes/i_tartarus.lua",
    "mods/data/biomes/n_ephyra.lua",
    "mods/data/biomes/o_thessaly.lua",
    "mods/data/biomes/p_olympus.lua",
    "mods/data/biomes/q_summit.lua",
}

local function mergeMap(target, source)
    for key, value in pairs(source or {}) do
        target[key] = value
    end
end

local function mergeNpcGroups(target, source)
    for _, groupKey in ipairs(source.orderedIds or {}) do
        if not target[groupKey] then
            local sourceGroup = source[groupKey]
            target[groupKey] = {
                id = sourceGroup.id,
                label = sourceGroup.label,
                actualNPCName = sourceGroup.actualNPCName,
                definitions = {},
                lookup = {},
            }
            target.orderedIds[#target.orderedIds + 1] = groupKey
        end

        local targetGroup = target[groupKey]
        local sourceGroup = source[groupKey]
        for _, def in ipairs(sourceGroup.definitions or {}) do
            targetGroup.definitions[#targetGroup.definitions + 1] = def
        end
        mergeMap(targetGroup.lookup, sourceGroup.lookup)
    end
end

local function appendBiome(target, biome)
    target[#target + 1] = biome
    target.ordered[#target.ordered + 1] = biome
    target[biome.key] = biome
end

local function appendSettings(target, settings)
    for _, setting in ipairs(settings or {}) do
        target[#target + 1] = setting
    end
end

function biomes.load(args)
    local settings = import("mods/data/settings_builder.lua", nil, {
        definitions = args.definitions,
    })
    local builder = import("mods/data/biome_builder.lua")
    local catalogBuilder = import("mods/data/catalog_builder.lua")
    local ordered = {}
    local lookup = {}
    local controls = {}
    local catalog = {
        biomes = { ordered = {} },
        npcs = { orderedIds = {} },
    }

    for _, importPath in ipairs(BIOME_IMPORTS) do
        local bundle = import(importPath, nil, {
            builder = builder,
            catalog = catalogBuilder,
            settings = settings,
            definitions = args.definitions,
        })
        local definition = bundle.definition
        local biome = bundle.biome
        ordered[#ordered + 1] = biome
        lookup[definition.key] = biome
        appendBiome(catalog.biomes, biome)
        mergeNpcGroups(catalog.npcs, bundle.npcGroups)
        appendSettings(controls, bundle.settings)
    end

    return {
        ordered = ordered,
        lookup = lookup,
        catalog = catalog,
        controls = controls,
    }
end

return biomes
