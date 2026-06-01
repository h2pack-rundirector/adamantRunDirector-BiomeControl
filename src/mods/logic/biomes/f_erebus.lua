local deps = ...
local module = {}
local resolver = deps.resolver
local roomPatches = deps.roomPatches

local TRIAL_ROOMS = {
    "F_Combat05", "F_Combat06", "F_Combat07",
    "F_Combat11", "F_Combat12", "F_Combat13",
    "F_Combat14", "F_Combat15", "F_Combat16",
    "F_Combat17", "F_Combat18", "F_Combat20",
}

local function injectForcedTrialReward(plan, runtime, log)
    local trial = resolver.roomInfo("F", "Trial")
    if not trial then
        return
    end

    local control = runtime.controls.get(trial.controlName)
    if control:mode() ~= "forced" then
        return
    end

    local minValue, maxValue = control:range()
    for _, roomKey in ipairs(TRIAL_ROOMS) do
        if RoomSetData.F and RoomSetData.F[roomKey] then
            roomPatches.forceRoomBetweenRange(plan, trial, roomKey, minValue, maxValue, {
                ForcedReward = "Devotion",
            })
            log("Deterministically injected trial reward into " .. roomKey)
            break
        end
    end
end

function module.buildPatchPlan(host, runtime, plan)
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("F", "Arachne"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("F", "Fountain"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("F", "Shop"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("F", "Treant"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("F", "FogEmitter"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.minibossInfo("F", "Assassin"))
    injectForcedTrialReward(plan, runtime, host.logIf)
end

return module
