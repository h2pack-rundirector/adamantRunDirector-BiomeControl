local builder = {}

local function cloneData(data)
    local copy = {}
    for key, value in pairs(data or {}) do
        copy[key] = value
    end
    return copy
end

function builder.room(biome)
    return {
        story = function(id, opts)
            opts = opts or {}
            local entry = cloneData(opts)
            entry.id = id
            entry.type = "Story"
            entry.biome = biome.key
            entry.region = biome.label
            entry.label = opts.label or "Story"
            return entry
        end,
        trial = function(opts)
            opts = cloneData(opts)
            opts.id = opts.id or "Trial"
            opts.type = "Trial"
            opts.biome = biome.key
            opts.region = biome.label
            opts.label = opts.label or "Trial"
            return opts
        end,
        fountain = function(opts)
            opts = cloneData(opts)
            opts.id = opts.id or "Fountain"
            opts.type = "Fountain"
            opts.biome = biome.key
            opts.region = biome.label
            opts.label = opts.label or "Fountain"
            return opts
        end,
        shop = function(opts)
            opts = cloneData(opts)
            opts.id = opts.id or "Shop"
            opts.type = "Shop"
            opts.biome = biome.key
            opts.region = biome.label
            opts.label = opts.label or "Shop"
            return opts
        end,
        minibossDepth = function(id, opts)
            opts = opts or {}
            local entry = cloneData(opts)
            entry.id = id
            entry.type = "MiniBoss"
            entry.biome = biome.key
            entry.region = biome.label
            entry.label = opts.label or string.format("%s (%s)", id, biome.label)
            return entry
        end,
    }
end

function builder.npc(biome)
    return function(id, opts)
        opts = opts or {}
        local entry = cloneData(opts)
        entry.id = id
        entry.biome = biome.key
        entry.region = biome.label
        entry.label = opts.label or id
        entry.groupKey = opts.groupKey or id
        return entry
    end
end

return builder
