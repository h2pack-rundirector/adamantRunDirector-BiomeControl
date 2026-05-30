local module = {}
local definitions
local GetRunState
local CreateStoreReader
local godAvailability

local function BindLogic()
    local priorityGodByLootKey = {}

    for _, god in ipairs(definitions.priorityGods or {}) do
        priorityGodByLootKey[god.lootKey] = god.label
    end

    local function IsPriorityLootAvailable(store, lootKey)
        if lootKey == "" then
            return true
        end

        local godKey = priorityGodByLootKey[lootKey]
        if not godKey then
            return true
        end

        return godAvailability.isAvailable(store, godKey)
    end

    local function AvailablePriorityKey(store, lootKey)
        lootKey = lootKey or ""
        if lootKey ~= "" and not IsPriorityLootAvailable(store, lootKey) then
            return ""
        end
        return lootKey
    end

    local function PriorityKeyForBiome(store, read, biomeIndex)
        biomeIndex = math.max((biomeIndex or 0) - 1, 0)
        if biomeIndex == 0 then return AvailablePriorityKey(store, read("PriorityBiome1")) end
        if biomeIndex == 1 then return AvailablePriorityKey(store, read("PriorityBiome2")) end
        if biomeIndex == 2 then return AvailablePriorityKey(store, read("PriorityBiome3")) end
        if biomeIndex == 3 then return AvailablePriorityKey(store, read("PriorityBiome4")) end
        return ""
    end

    local function PriorityKeyForTrial(store, read, trialIndex)
        if trialIndex == 1 then return AvailablePriorityKey(store, read("PriorityTrial1")) end
        if trialIndex == 2 then return AvailablePriorityKey(store, read("PriorityTrial2")) end
        return ""
    end

    function module.registerHooks(host, store)
        local read = CreateStoreReader(store)

        host.hooks.wrap("GetEligibleLootNames", function(base, excludeLootNames)
            if not host.isEnabled() then return base(excludeLootNames) end

            local state = GetRunState(store)
            if not state then return base(excludeLootNames) end
            state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}

            local eligible = base(excludeLootNames)
            local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
            local priorityLootKey = PriorityKeyForBiome(store, read, currentBiomeIndex)
            local isPriorityMode = read("PrioritizeSpecificRewardEnabled") and priorityLootKey ~= "" and
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
            if read("PrioritizeSpecificRewardEnabled") and lootName == PriorityKeyForBiome(store, read, currentBiomeIndex) then
                state.BiomePrioritySatisfied[currentBiomeIndex] = true
            end
            return result
        end)

        host.hooks.wrap("SetupRoomReward", function(base, currentRun, room, previouslyChosenRewards, args)
            base(currentRun, room, previouslyChosenRewards, args)
            if not host.isEnabled() then return end

            local chosenRewardType = args and args.ChosenRewardType or room.ChosenRewardType
            if chosenRewardType ~= "Devotion" or not room or not room.Encounter then return end
            if not read("PrioritizeTrialRewardEnabled") then return end

            local prioA = PriorityKeyForTrial(store, read, 1)
            local prioB = PriorityKeyForTrial(store, read, 2)
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
end

function module.bind(deps)
    definitions = deps.definitions
    GetRunState = deps.GetRunState
    CreateStoreReader = deps.CreateStoreReader
    godAvailability = deps.godAvailability
    BindLogic()
    return module
end

return module
