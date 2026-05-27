local biomes = {}

local BIOME_IMPORTS = {
    "mods/data3/biomes/f_erebus.lua",
    "mods/data3/biomes/g_oceanus.lua",
    "mods/data3/biomes/h_fields.lua",
    "mods/data3/biomes/i_tartarus.lua",
    "mods/data3/biomes/n_ephyra.lua",
    "mods/data3/biomes/o_thessaly.lua",
    "mods/data3/biomes/p_olympus.lua",
    "mods/data3/biomes/q_summit.lua",
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
                region = sourceGroup.region,
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

local function appendControllers(target, controllers)
    for _, controller in ipairs(controllers or {}) do
        target[#target + 1] = controller
    end
end

function biomes.load(args)
    local controller = import("mods/data3/controller_builder.lua", nil, {
        definitions = args.definitions,
    })
    local builder = import("mods/data3/biome_builder.lua")
    local catalogBuilder = import("mods/data3/catalog_builder.lua")
    local ordered = {}
    local lookup = {}
    local controllers = {}
    local catalog = {
        biomes = { ordered = {} },
        npcs = { orderedIds = {} },
    }

    for _, importPath in ipairs(BIOME_IMPORTS) do
        local bundle = import(importPath, nil, {
            builder = builder,
            catalog = catalogBuilder,
            controller = controller,
            definitions = args.definitions,
        })
        local definition = bundle.definition
        local biome = bundle.biome
        ordered[#ordered + 1] = biome
        lookup[definition.key] = biome
        appendBiome(catalog.biomes, biome)
        mergeNpcGroups(catalog.npcs, bundle.npcGroups)
        appendControllers(controllers, bundle.controllers)
    end

    return {
        ordered = ordered,
        lookup = lookup,
        catalog = catalog,
        controllers = controllers,
    }
end

return biomes
