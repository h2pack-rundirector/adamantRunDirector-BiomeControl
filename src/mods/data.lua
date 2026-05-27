local data = {}

local definitions = import("mods/data/definitions.lua")
local biomeLoader = import("mods/data/biomes.lua")
local catalog = import("mods/data/catalog.lua")
local baseStorage = import("mods/data/base_storage.lua")
local biomeRegistry = biomeLoader.load()

local function appendNodes(target, nodes)
    for _, node in ipairs(nodes or {}) do
        target[#target + 1] = node
    end
end

local catalogModel = catalog.create({
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
    local nodes = baseStorage.build()
    appendNodes(nodes, catalogModel.storageNodes)
    return nodes
end

return data
