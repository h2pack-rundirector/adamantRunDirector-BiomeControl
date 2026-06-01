local deps = ...
local module = {}
local resolver = deps.resolver
local roomPatches = deps.roomPatches

local TRIAL_ROOMS = {
    "G_Combat02", "G_Combat03", "G_Combat09",
    "G_Combat10", "G_Combat11", "G_Combat12",
    "G_Combat13", "G_Combat14", "G_Combat15",
    "G_Combat16", "G_Combat17",
}

local function injectForcedTrialReward(plan, runtime, log)
    local trial = resolver.roomInfo("G", "Trial")
    if not trial then
        return
    end

    local control = runtime.controls.get(trial.controlName)
    if control:mode() ~= "forced" then
        return
    end

    local minValue, maxValue = control:range()
    for _, roomKey in ipairs(TRIAL_ROOMS) do
        if RoomSetData.G and RoomSetData.G[roomKey] then
            roomPatches.forceRoomBetweenRange(plan, trial, roomKey, minValue, maxValue, {
                ForcedReward = "Devotion",
            })
            log("Deterministically injected trial reward into " .. roomKey)
            break
        end
    end
end

function module.buildPatchPlan(host, runtime, plan)
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("G", "Narcissus"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("G", "Fountain"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("G", "Shop"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("G", "WaterUnit"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("G", "Crawler"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("G", "Jellyfish"))
    injectForcedTrialReward(plan, runtime, host.logIf)
end

return module
