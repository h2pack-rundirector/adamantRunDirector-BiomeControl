local deps = ...
local module = {}
local resolver = deps.resolver
local roomPatches = deps.roomPatches

function module.buildPatchPlan(_, runtime, plan)
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("P", "Dionysus"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("P", "Fountain"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("P", "Shop"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("P", "Talos"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("P", "Dragon"))
end

return module
