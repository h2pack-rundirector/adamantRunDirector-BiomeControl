local deps = ...
local catalog = deps.catalog

local definition = {
    key = "Q",
    label = "Summit",
    region = "Surface",
    ui = "mods/ui/biomes/q_summit.lua",
}

return catalog.biomeBundle(definition, {
    rooms = catalog.rooms({}),
    npcs = catalog.npcs({}),
})
