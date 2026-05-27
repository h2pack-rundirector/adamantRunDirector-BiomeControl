local data = {}

local definitions = import("mods/data3/definitions.lua")
local baseStorage = import("mods/data3/base_storage.lua")
local biomeLoader = import("mods/data3/biomes.lua")
local storageBuilder = import("mods/data3/storage_builder.lua")

local function appendNodes(target, nodes)
    for _, node in ipairs(nodes or {}) do
        target[#target + 1] = node
    end
end

local biomeRegistry = biomeLoader.load({
    definitions = definitions,
})

data.definitions = definitions
data.biomes = biomeRegistry
data.catalog = biomeRegistry.catalog

data.storage = {}
function data.storage.build()
    local nodes = baseStorage.build()
    appendNodes(nodes, storageBuilder.fromControllers(biomeRegistry.controllers))
    return nodes
end

return data
