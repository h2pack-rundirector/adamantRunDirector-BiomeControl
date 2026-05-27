local deps = ...
local catalog = deps.catalog

local definition = {
    key = "Q",
    label = "Summit",
    region = "Surface",
    ui = "mods/ui/biomes/q_summit.lua",
    ui3 = "mods/ui3/biomes/q_summit.lua",
}

return catalog.biomeBundle(definition, {
    rooms = catalog.rooms({}),
    npcs = catalog.npcs({}),
})
