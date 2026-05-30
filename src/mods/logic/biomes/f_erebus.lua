local deps = ...
local module = {}
local catalog = deps.catalog

local TRIAL_ROOMS = {
    "F_Combat05", "F_Combat06", "F_Combat07",
    "F_Combat11", "F_Combat12", "F_Combat13",
    "F_Combat14", "F_Combat15", "F_Combat16",
    "F_Combat17", "F_Combat18", "F_Combat20",
}

local function setForcedReward(plan, roomSetKey, roomKey, rewardName, minValue, maxValue)
    local roomSet = RoomSetData[roomSetKey]
    if not roomSet or not roomSet[roomKey] then return end
    plan:setMany(roomSet[roomKey], {
        ForcedReward = rewardName,
        ForceAtBiomeDepthMin = minValue,
        ForceAtBiomeDepthMax = maxValue,
    })
end

local function injectForcedTrialReward(plan, runtime, log)
    local trialDef = catalog.biomes.F.rooms.Trial
    if not trialDef then
        return
    end

    local control = runtime.controls.get(trialDef.setting.name)
    if control:mode() ~= "forced" then
        return
    end

    local minValue, maxValue = control:range()
    for _, roomKey in ipairs(TRIAL_ROOMS) do
        if RoomSetData.F and RoomSetData.F[roomKey] then
            setForcedReward(plan, "F", roomKey, "Devotion", minValue, maxValue)
            log("Deterministically injected trial reward into " .. roomKey)
            break
        end
    end
end

function module.buildPatchPlan(host, runtime, plan)
    injectForcedTrialReward(plan, runtime, host.logIf)
end

return module
