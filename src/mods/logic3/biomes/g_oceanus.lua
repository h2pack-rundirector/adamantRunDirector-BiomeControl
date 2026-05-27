local deps = ...
local module = {}
local catalog = deps.catalog
local controllerReader = deps.controllerReader

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

local function injectForcedTrialReward(plan, store, log)
    local trialDef = catalog.biomes.G.rooms.Trial
    if not trialDef or controllerReader.readMode(store, trialDef.controller) ~= "forced" then
        return
    end

    local minValue, maxValue = controllerReader.readRange(store, trialDef.controller)
    for _, roomKey in ipairs(TRIAL_ROOMS) do
        if RoomSetData.G and RoomSetData.G[roomKey] then
            setForcedReward(plan, "G", roomKey, "Devotion", minValue, maxValue)
            log("Deterministically injected trial reward into " .. roomKey)
            break
        end
    end
end

function module.buildPatchPlan(plan, host, store)
    injectForcedTrialReward(plan, store, host.logIf)
end

return module
