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

function biomes.load()
    local ordered = {}
    local lookup = {}

    for _, importPath in ipairs(BIOME_IMPORTS) do
        local biome = import(importPath)
        ordered[#ordered + 1] = biome
        lookup[biome.key] = biome
    end

    return {
        ordered = ordered,
        lookup = lookup,
    }
end

return biomes
