local deps = ...
local module = {}
local resolver = deps.resolver
local roomPatches = deps.roomPatches

function module.buildPatchPlan(_, runtime, plan)
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("I", "RatCatcher"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("I", "GoldElemental"))
end

return module
