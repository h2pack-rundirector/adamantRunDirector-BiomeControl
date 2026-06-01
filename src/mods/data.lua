local data = {}

local controlDefs = import("mods/data/control_defs.lua")
local biomeLoader = import("mods/data/biomes.lua")
local resolverModule = import("mods/data/resolver.lua")

local biomeRegistry = biomeLoader.load()
local resolver = resolverModule.create(biomeRegistry.catalog)
local settingsControls = import("mods/data/controls/settings.lua", nil, {
    controlDefs = controlDefs,
})
local rewardPriorityControls = import("mods/data/controls/reward_priority.lua", nil, {
    controlDefs = controlDefs,
})
local dreamRouteControl = import("mods/data/controls/dream_route.lua", nil, {
    controlDefs = controlDefs,
    resolver = resolver,
})

function data.buildStorage()
    return {}
end

function data.buildControlTemplates(deps)
    return import("mods/controls/templates.lua", nil, deps)
end

function data.buildControls()
    local controls = {}

    local function append(control)
        if controls[control.name] ~= nil then
            error("duplicate BiomeControl control '" .. tostring(control.name) .. "'", 0)
        end
        controls[control.name] = control
    end

    local function appendAll(list)
        for _, control in ipairs(list or {}) do
            append(control)
        end
    end

    appendAll(settingsControls.build())
    appendAll(rewardPriorityControls.build())
    append(dreamRouteControl.build())
    appendAll(biomeRegistry.controls)

    return controls
end

data.resolver = resolver

return data
