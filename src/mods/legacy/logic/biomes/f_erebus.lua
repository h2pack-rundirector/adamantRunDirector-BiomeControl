local module = {}
local catalog
local CreateStoreReader

local TRIAL_ROOMS = {
    "F_Combat05", "F_Combat06", "F_Combat07",
    "F_Combat11", "F_Combat12", "F_Combat13",
    "F_Combat14", "F_Combat15", "F_Combat16",
    "F_Combat17", "F_Combat18", "F_Combat20",
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
    local trialDef = catalog.roomLookup.Trial and catalog.roomLookup.Trial.F
    if not trialDef or catalog.GetModeValue(read, trialDef) ~= "forced" then
        return
    end

    for _, roomKey in ipairs(TRIAL_ROOMS) do
        if RoomSetData.F and RoomSetData.F[roomKey] then
            SetForcedReward(plan, "F", roomKey, "Devotion", read(trialDef.rangeMinAlias), read(trialDef.rangeMaxAlias))
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
