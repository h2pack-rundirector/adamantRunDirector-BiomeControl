local deps = ...
local module = {}

local roomPatches = import("mods/logic/biomes/room_patches.lua", nil, deps)
local biomeLogic = {}
local biomeDeps = {
    resolver = deps.resolver,
    roomPatches = roomPatches,
}

for _, moduleInfo in ipairs(deps.resolver.biomeLogicModules()) do
    biomeLogic[#biomeLogic + 1] = import(moduleInfo.path, nil, biomeDeps)
end

function module.buildPatchPlan(host, runtime, plan)
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
