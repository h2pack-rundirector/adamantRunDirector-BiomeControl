local module = {}
local catalog
local CreateStoreReader

local TRIAL_ROOMS = {
    "G_Combat02", "G_Combat03", "G_Combat09",
    "G_Combat10", "G_Combat11", "G_Combat12",
    "G_Combat13", "G_Combat14", "G_Combat15",
    "G_Combat16", "G_Combat17",
}

local function SetForcedReward(plan, roomSetKey, roomKey, rewardName, minValue, maxValue)
    local roomSet = RoomSetData[roomSetKey]
    if not roomSet or not roomSet[roomKey] then return end
    plan:setMany(roomSet[roomKey], {
        ForcedReward = rewardName,
        ForceAtBiomeDepthMin = minValue,
        ForceAtBiomeDepthMax = maxValue,
    })
end

local function InjectForcedTrialReward(plan, read, log)
    local trialDef = catalog.roomLookup.Trial and catalog.roomLookup.Trial.G
    if not trialDef or catalog.GetModeValue(read, trialDef) ~= "forced" then
        return
    end

    for _, roomKey in ipairs(TRIAL_ROOMS) do
        if RoomSetData.G and RoomSetData.G[roomKey] then
            SetForcedReward(plan, "G", roomKey, "Devotion", read(trialDef.rangeMinAlias), read(trialDef.rangeMaxAlias))
            log("Deterministically injected trial reward into " .. roomKey)
            break
        end
    end
end

function module.buildPatchPlan(plan, host, store)
    InjectForcedTrialReward(plan, CreateStoreReader(store), host.logIf)
end

function module.bind(deps)
    catalog = deps.catalog
    CreateStoreReader = deps.CreateStoreReader
    return module
end

return module
