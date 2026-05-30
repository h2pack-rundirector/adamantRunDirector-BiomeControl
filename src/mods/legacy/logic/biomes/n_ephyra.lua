local module = {}
local catalog
local CreateStoreReader

local function isOptionBanned(packedValue, bit)
    return bit32.band(packedValue or 0, bit32.lshift(1, bit)) ~= 0
end

local function filterRewardStore(list, packedValue, options)
    local banned = {}
    for _, option in ipairs(options) do
        if isOptionBanned(packedValue, option.bit) then
            banned[option.name] = true
        end
    end

    local newList = {}
    for _, entry in ipairs(list or {}) do
        if not banned[entry.Name] then
            table.insert(newList, entry)
        end
    end
    return newList
end

local function forEachRewardStoreTarget(storeKey, callback)
    local applied = false

    if RewardStoreData and type(RewardStoreData[storeKey]) == "table" then
        callback(RewardStoreData)
        applied = true
    end

    if CurrentRun and CurrentRun.RewardStores and type(CurrentRun.RewardStores[storeKey]) == "table" then
        callback(CurrentRun.RewardStores)
        applied = true
    end

    return applied
end

local function findRewardEntry(store, storeKey, rewardName)
    local list = store and store[storeKey]
    if type(list) ~= "table" then
        return nil
    end

    for _, entry in ipairs(list) do
        if entry.Name == rewardName then
            return entry
        end
    end
    return nil
end

local function copyRewardEntry(entry, replacementName)
    local copy = {}
    for key, value in pairs(entry) do
        copy[key] = value
    end
    copy.Name = replacementName
    copy.GameStateRequirements = nil
    return copy
end

local function appendImpossibleRequirement(plan, roomKey)
    local room = RoomData and RoomData[roomKey]
    if not room then return end
    plan:appendUnique(room, "GameStateRequirements", {
        Path = { "CurrentRun", "BiomeDepthCache" },
        Comparison = "==",
        Value = -1,
    })
end

local function replaceHermesInEphyra(plan, read, log)
    local replacement = read("ReplaceHermesInEphyra") or ""
    if replacement == "" then
        return
    end

    local applied = false
    forEachRewardStoreTarget("HubRewards", function(store)
        local hermesHubReward = findRewardEntry(store, "HubRewards", "HermesUpgrade")
        if hermesHubReward then
            plan:setElement(store, "HubRewards", hermesHubReward, copyRewardEntry(hermesHubReward, replacement))
            applied = true
        end
    end)

    if applied then
        log("Replaced Hermes in Ephyra HubRewards with %s", replacement)
    end
end

local function blockReplacementFromArtemis(plan, read, log)
    local replacement = read("ReplaceHermesInEphyra") or ""
    if replacement == "" or replacement == "HermesUpgrade" then
        return
    end

    if EncounterData == nil or EncounterData.BaseArtemisCombat == nil then
        return
    end

    plan:appendUnique(EncounterData.BaseArtemisCombat, "RequireNotRoomReward", replacement)

    log("Added %s to BaseArtemisCombat.RequireNotRoomReward", replacement)
end

local function applyEphyraRooms(plan, read, log)
    local storyMode = catalog.GetModeValue(read, "EphyraStoryMode")
    if storyMode == "forced" and RoomData and RoomData.N_Story01 then
        plan:setMany(RoomData.N_Story01, { AlwaysForce = true })
        log("Forced Ephyra story room when eligible")
    elseif storyMode == "disabled" then
        appendImpossibleRequirement(plan, "N_Story01")
        log("Disabled Ephyra story room")
    end

    local minibossMode = catalog.GetModeValue(read, "EphyraMiniBossMode")
    if minibossMode == "satyr_crossbow" then
        plan:setMany(RoomData.N_MiniBoss01, { AlwaysForce = true })
        appendImpossibleRequirement(plan, "N_MiniBoss02")
        log("Forced Ephyra Satyr Champion miniboss")
    elseif minibossMode == "boar" then
        plan:setMany(RoomData.N_MiniBoss02, { AlwaysForce = true })
        appendImpossibleRequirement(plan, "N_MiniBoss01")
        log("Forced Ephyra Erymanthian Boar miniboss")
    elseif minibossMode == "disabled" then
        appendImpossibleRequirement(plan, "N_MiniBoss01")
        appendImpossibleRequirement(plan, "N_MiniBoss02")
        log("Disabled both Ephyra miniboss rooms")
    end
end

local function applyEphyraRewardBans(plan, read, log)
    local normalRewards = catalog.packedRewardFields.PackedBannedEphyraSubRoomRewards
    local hardRewards = catalog.packedRewardFields.PackedBannedEphyraSubRoomRewardsHard
    local packedNormal = read(normalRewards.alias) or 0
    local packedHard = read(hardRewards.alias) or 0

    local appliedNormal = forEachRewardStoreTarget("SubRoomRewards", function(store)
        plan:transform(store, "SubRoomRewards", function(list)
            return filterRewardStore(list, packedNormal, normalRewards.options)
        end)
    end)
    local appliedHard = forEachRewardStoreTarget("SubRoomRewardsHard", function(store)
        plan:transform(store, "SubRoomRewardsHard", function(list)
            return filterRewardStore(list, packedHard, hardRewards.options)
        end)
    end)

    if appliedNormal or appliedHard then
        log("Applied Ephyra subroom reward bans")
    end
end

function module.buildPatchPlan(plan, host, store)
    local read = CreateStoreReader(store)
    local log = host.logIf
    replaceHermesInEphyra(plan, read, log)
    blockReplacementFromArtemis(plan, read, log)
    applyEphyraRooms(plan, read, log)
    applyEphyraRewardBans(plan, read, log)
end

function module.bind(deps)
    catalog = deps.catalog
    CreateStoreReader = deps.CreateStoreReader
    return module
end

return module
