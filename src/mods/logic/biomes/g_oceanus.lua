local deps = ...
local module = {}
local catalog = deps.catalog

local TRIAL_ROOMS = {
    "G_Combat02", "G_Combat03", "G_Combat09",
    "G_Combat10", "G_Combat11", "G_Combat12",
    "G_Combat13", "G_Combat14", "G_Combat15",
    "G_Combat16", "G_Combat17",
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
    local trialDef = catalog.biomes.G.rooms.Trial
    if not trialDef then
        return
    end

    local control = runtime.controls.get(trialDef.setting.name)
    if control:mode() ~= "forced" then
        return
    end

    local minValue, maxValue = control:range()
    for _, roomKey in ipairs(TRIAL_ROOMS) do
        if RoomSetData.G and RoomSetData.G[roomKey] then
            setForcedReward(plan, "G", roomKey, "Devotion", minValue, maxValue)
            log("Deterministically injected trial reward into " .. roomKey)
            break
        end
    end
end

function module.buildPatchPlan(host, runtime, plan)
    injectForcedTrialReward(plan, runtime, host.logIf)
end

return module
