local deps = ...
local module = {}

local roomModes = import("mods/logic3/biomes/room_modes.lua", nil, deps)
local biomeLogic = {}

for _, biome in ipairs(deps.catalog.biomes.ordered or {}) do
    if biome.logic then
        biomeLogic[#biomeLogic + 1] = import(biome.logic, nil, deps)
    end
end

function module.buildPatchPlan(plan, host, store)
    if roomModes.buildPatchPlan then
        roomModes.buildPatchPlan(plan, host, store)
    end
    for _, logic in ipairs(biomeLogic) do
        if logic.buildPatchPlan then
            logic.buildPatchPlan(plan, host, store)
        end
    end
end

function module.registerHooks(host, store)
    for _, logic in ipairs(biomeLogic) do
        if logic.registerHooks then
            logic.registerHooks(host, store)
        end
    end
end

return module
