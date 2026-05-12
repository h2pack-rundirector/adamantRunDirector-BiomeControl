local data = {}

local definitions = import("mods/data/definitions.lua")
local biomeLoader = import("mods/data/biomes.lua")
local catalog = import("mods/data/catalog.lua")
local storage = import("mods/data/storage.lua")
local biomeRegistry = biomeLoader.load()

local catalogModel = catalog.create({
    definitions = definitions,
    biomes = biomeRegistry,
    defaults = {
        roomModeValues = definitions.roomModeValues,
        roomModeDisplayValues = definitions.roomModeDisplayValues,
    },
})

data.definitions = definitions
data.catalog = catalogModel

data.storage = {}
function data.storage.build()
    return storage.build(data)
end

return data
