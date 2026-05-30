local data = {}

local definitions = import("mods/data/definitions.lua")
local baseStorage = import("mods/data/base_storage.lua")
local settings = import("mods/data/settings_builder.lua", nil, {
    definitions = definitions,
})
local baseControls = import("mods/data/base_controls.lua", nil, {
    settings = settings,
})
local biomeLoader = import("mods/data/biomes.lua")
local controlTemplates = import("mods/controls/templates.lua")

local biomeRegistry = biomeLoader.load({
    definitions = definitions,
})

data.definitions = definitions
data.biomes = biomeRegistry
data.catalog = biomeRegistry.catalog

data.storage = {}
function data.storage.build()
    local nodes = baseStorage.build()
    return nodes
end

data.controls = {}

function data.controls.buildTemplates()
    return controlTemplates
end

function data.controls.build()
    local controls = {}
    local function append(control)
        if controls[control.name] ~= nil then
            error("duplicate BiomeControl control '" .. tostring(control.name) .. "'", 0)
        end
        controls[control.name] = control
    end
    for _, control in ipairs(baseControls.build()) do
        append(control)
    end
    for _, control in ipairs(biomeRegistry.controls or {}) do
        append(control)
    end
    return controls
end

return data
