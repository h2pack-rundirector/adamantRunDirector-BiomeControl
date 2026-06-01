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

local function patchTrialReward(plan, runtime, log)
    local trial = resolver.roomInfo("G", "Trial")
    if not trial then
        return
    end

    local control = runtime.controls.get(trial.controlName)
    local mode = control:mode()
    if mode == "forced" then
        local minValue, maxValue = control:range()
        for _, roomKey in ipairs(TRIAL_ROOMS) do
            if roomPatches.forceRoomBetweenRange(plan, trial, roomKey, minValue, maxValue, {
                ForcedReward = "Devotion",
            }) then
                log("Deterministically injected trial reward into " .. roomKey)
                break
            end
        end
        return
    end

    if mode == "disabled" then
        local applied = false
        for _, roomKey in ipairs(TRIAL_ROOMS) do
            if roomPatches.preventRoomReward(plan, trial, roomKey, "Devotion") then
                applied = true
            end
        end
        if applied then
            log("Suppressed Oceanus trial reward candidates")
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
    patchTrialReward(plan, runtime, host.logIf)
end

return module
