local deps = ...
local module = {}

local roomModes = import("mods/logic/biomes/room_modes.lua", nil, deps)
local biomeLogic = {}

for _, biome in ipairs(deps.catalog.biomes.ordered or {}) do
    if biome.logic then
        biomeLogic[#biomeLogic + 1] = import(biome.logic, nil, deps)
    end
end

function module.buildPatchPlan(host, runtime, plan)
    if roomModes.buildPatchPlan then
        roomModes.buildPatchPlan(host, runtime, plan)
    end
    for _, logic in ipairs(biomeLogic) do
        if logic.buildPatchPlan then
            logic.buildPatchPlan(host, runtime, plan)
        end
    end
end

function module.registerHooks(moduleRef)
    for _, logic in ipairs(biomeLogic) do
        if logic.registerHooks then
            logic.registerHooks(moduleRef)
        end
    end
end

return module
