local deps = ...
local module = {}
local catalog = deps.catalog
local controllerReader = deps.controllerReader

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

local function replaceHermesInEphyra(plan, store, log)
    local replacement = controllerReader.readValue(store, catalog.biomes.N.controls.ReplaceHermesInEphyra.controller) or ""
    if replacement == "" then
        return
    end

    local applied = false
    forEachRewardStoreTarget("HubRewards", function(rewardStore)
        local hermesHubReward = findRewardEntry(rewardStore, "HubRewards", "HermesUpgrade")
        if hermesHubReward then
            plan:setElement(rewardStore, "HubRewards", hermesHubReward, copyRewardEntry(hermesHubReward, replacement))
            applied = true
        end
    end)

    if applied then
        log("Replaced Hermes in Ephyra HubRewards with %s", replacement)
    end
end

local function blockReplacementFromArtemis(plan, store, log)
    local replacement = controllerReader.readValue(store, catalog.biomes.N.controls.ReplaceHermesInEphyra.controller) or ""
    if replacement == "" or replacement == "HermesUpgrade" then
        return
    end

    if EncounterData == nil or EncounterData.BaseArtemisCombat == nil then
        return
    end

    plan:appendUnique(EncounterData.BaseArtemisCombat, "RequireNotRoomReward", replacement)

    log("Added %s to BaseArtemisCombat.RequireNotRoomReward", replacement)
end

local function applyEphyraRooms(plan, store, log)
    local controls = catalog.biomes.N.controls
    local storyMode = controllerReader.readMode(store, controls.EphyraStoryMode.controller)
    if storyMode == "forced" and RoomData and RoomData.N_Story01 then
        plan:setMany(RoomData.N_Story01, { AlwaysForce = true })
        log("Forced Ephyra story room when eligible")
    elseif storyMode == "disabled" then
        appendImpossibleRequirement(plan, "N_Story01")
        log("Disabled Ephyra story room")
    end

    local minibossMode = controllerReader.readMode(store, controls.EphyraMiniBossMode.controller)
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

local function applyEphyraRewardBans(plan, store, log)
    local controls = catalog.biomes.N.controls
    local normalRewards = controls.PackedBannedEphyraSubRoomRewards.controller
    local hardRewards = controls.PackedBannedEphyraSubRoomRewardsHard.controller
    local packedNormal = controllerReader.readPacked(store, normalRewards)
    local packedHard = controllerReader.readPacked(store, hardRewards)

    local appliedNormal = forEachRewardStoreTarget("SubRoomRewards", function(rewardStore)
        plan:transform(rewardStore, "SubRoomRewards", function(list)
            return filterRewardStore(list, packedNormal, controllerReader.getPackedOptions(normalRewards))
        end)
    end)
    local appliedHard = forEachRewardStoreTarget("SubRoomRewardsHard", function(rewardStore)
        plan:transform(rewardStore, "SubRoomRewardsHard", function(list)
            return filterRewardStore(list, packedHard, controllerReader.getPackedOptions(hardRewards))
        end)
    end)

    if appliedNormal or appliedHard then
        log("Applied Ephyra subroom reward bans")
    end
end

function module.buildPatchPlan(plan, host, store)
    local log = host.logIf
    replaceHermesInEphyra(plan, store, log)
    blockReplacementFromArtemis(plan, store, log)
    applyEphyraRooms(plan, store, log)
    applyEphyraRewardBans(plan, store, log)
end

return module
