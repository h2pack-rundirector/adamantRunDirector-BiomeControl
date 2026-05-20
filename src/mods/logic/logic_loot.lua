local module = {}
local definitions
local GetRunState

local function BindLogic()
    local GOD_AVAILABILITY_INTEGRATION = "run-director.god-availability"

    local priorityGodByLootKey = {}

    for _, god in ipairs(definitions.priorityGods or {}) do
        priorityGodByLootKey[god.lootKey] = god.label
    end

    local function IsPriorityLootAvailable(host, lootKey)
        if lootKey == "" then
            return true
        end

        local godKey = priorityGodByLootKey[lootKey]
        if not godKey then
            return true
        end

        return host.integrations.invoke(GOD_AVAILABILITY_INTEGRATION, "isAvailable", true, godKey) ~= false
    end

    local function AvailablePriorityKey(host, lootKey)
        lootKey = lootKey or ""
        if lootKey ~= "" and not IsPriorityLootAvailable(host, lootKey) then
            return ""
        end
        return lootKey
    end

    local function PriorityKeyForBiome(host, read, biomeIndex)
        biomeIndex = math.max((biomeIndex or 0) - 1, 0)
        if biomeIndex == 0 then return AvailablePriorityKey(host, read("PriorityBiome1")) end
        if biomeIndex == 1 then return AvailablePriorityKey(host, read("PriorityBiome2")) end
        if biomeIndex == 2 then return AvailablePriorityKey(host, read("PriorityBiome3")) end
        if biomeIndex == 3 then return AvailablePriorityKey(host, read("PriorityBiome4")) end
        return ""
    end

    local function PriorityKeyForTrial(host, read, trialIndex)
        if trialIndex == 1 then return AvailablePriorityKey(host, read("PriorityTrial1")) end
        if trialIndex == 2 then return AvailablePriorityKey(host, read("PriorityTrial2")) end
        return ""
    end

    function module.registerHooks(host, store)
        local read = store.read

        host.hooks.wrap("GetEligibleLootNames", function(base, excludeLootNames)
            if not host.isEnabled() then return base(excludeLootNames) end

            local state = GetRunState(host, store)
            if not state then return base(excludeLootNames) end
            state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}

            local eligible = base(excludeLootNames)
            local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
            local priorityLootKey = PriorityKeyForBiome(host, read, currentBiomeIndex)
            local isPriorityMode = read("PrioritizeSpecificRewardEnabled") and priorityLootKey ~= "" and
                not state.BiomePrioritySatisfied[currentBiomeIndex]

            if isPriorityMode and Contains(eligible, priorityLootKey) then
                return { priorityLootKey }
            end

            return eligible
        end)

        host.hooks.wrap("GiveLoot", function(base, args)
            if not host.isEnabled() then return base(args) end

            local state = GetRunState(host, store)
            if not state then return base(args) end

            local result = base(args)
            local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
            local lootName = args and (args.ForceLootName or args.Name)
            if read("PrioritizeSpecificRewardEnabled") and lootName == PriorityKeyForBiome(host, read, currentBiomeIndex) then
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

            local prioA = PriorityKeyForTrial(host, read, 1)
            local prioB = PriorityKeyForTrial(host, read, 2)
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
    BindLogic()
    return module
end

return module
