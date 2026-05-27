local deps = ...
local module = {}
local definitions = deps.definitions
local GetRunState = deps.GetRunState
local godAvailability = deps.godAvailability

local priorityGodByLootKey = {}

for _, god in ipairs(definitions.priorityGods or {}) do
    priorityGodByLootKey[god.lootKey] = god.label
end

local function isPriorityLootAvailable(store, lootKey)
    if lootKey == "" then
        return true
    end

    local godKey = priorityGodByLootKey[lootKey]
    if not godKey then
        return true
    end

    return godAvailability.isAvailable(store, godKey)
end

local function availablePriorityKey(store, lootKey)
    lootKey = lootKey or ""
    if lootKey ~= "" and not isPriorityLootAvailable(store, lootKey) then
        return ""
    end
    return lootKey
end

local function priorityKeyForBiome(store, biomeIndex)
    biomeIndex = math.max((biomeIndex or 0) - 1, 0)
    if biomeIndex == 0 then return availablePriorityKey(store, store.read("PriorityBiome1")) end
    if biomeIndex == 1 then return availablePriorityKey(store, store.read("PriorityBiome2")) end
    if biomeIndex == 2 then return availablePriorityKey(store, store.read("PriorityBiome3")) end
    if biomeIndex == 3 then return availablePriorityKey(store, store.read("PriorityBiome4")) end
    return ""
end

local function priorityKeyForTrial(store, trialIndex)
    if trialIndex == 1 then return availablePriorityKey(store, store.read("PriorityTrial1")) end
    if trialIndex == 2 then return availablePriorityKey(store, store.read("PriorityTrial2")) end
    return ""
end

function module.registerHooks(host, store)
    host.hooks.wrap("GetEligibleLootNames", function(base, excludeLootNames)
        if not host.isEnabled() then return base(excludeLootNames) end

        local state = GetRunState(store)
        if not state then return base(excludeLootNames) end
        state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}

        local eligible = base(excludeLootNames)
        local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
        local priorityLootKey = priorityKeyForBiome(store, currentBiomeIndex)
        local isPriorityMode = store.read("PrioritizeSpecificRewardEnabled") and priorityLootKey ~= "" and
            not state.BiomePrioritySatisfied[currentBiomeIndex]

        if isPriorityMode and Contains(eligible, priorityLootKey) then
            return { priorityLootKey }
        end

        return eligible
    end)

    host.hooks.wrap("GiveLoot", function(base, args)
        if not host.isEnabled() then return base(args) end

        local state = GetRunState(store)
        if not state then return base(args) end

        local result = base(args)
        local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
        local lootName = args and (args.ForceLootName or args.Name)
        if store.read("PrioritizeSpecificRewardEnabled") and lootName == priorityKeyForBiome(store, currentBiomeIndex) then
            state.BiomePrioritySatisfied[currentBiomeIndex] = true
        end
        return result
    end)

    host.hooks.wrap("SetupRoomReward", function(base, currentRun, room, previouslyChosenRewards, args)
        base(currentRun, room, previouslyChosenRewards, args)
        if not host.isEnabled() then return end

        local chosenRewardType = args and args.ChosenRewardType or room.ChosenRewardType
        if chosenRewardType ~= "Devotion" or not room or not room.Encounter then return end
        if not store.read("PrioritizeTrialRewardEnabled") then return end

        local prioA = priorityKeyForTrial(store, 1)
        local prioB = priorityKeyForTrial(store, 2)
        local interacted = GetInteractedGodsThisRun() or {}
        if prioA ~= "" and prioB ~= "" and prioA ~= prioB and
            Contains(interacted, prioA) and Contains(interacted, prioB) and
            Contains(GetEligibleLootNames(), prioA) and
            Contains(GetEligibleLootNames({ prioA }), prioB) then
            room.Encounter.LootAName = prioA
            room.Encounter.LootBName = prioB
        end
    end)
end

return module
