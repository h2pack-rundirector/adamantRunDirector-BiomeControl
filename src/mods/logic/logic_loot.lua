local deps = ...
local module = {}
local GetRunState = deps.GetRunState

local function priorityKeyForBiome(runtime, biomeIndex)
    biomeIndex = math.max((biomeIndex or 0) - 1, 0)
    if biomeIndex == 0 then return runtime.controls.get("PriorityBiome1"):readAvailable(runtime.data) end
    if biomeIndex == 1 then return runtime.controls.get("PriorityBiome2"):readAvailable(runtime.data) end
    if biomeIndex == 2 then return runtime.controls.get("PriorityBiome3"):readAvailable(runtime.data) end
    if biomeIndex == 3 then return runtime.controls.get("PriorityBiome4"):readAvailable(runtime.data) end
    return ""
end

local function priorityKeyForTrial(runtime, trialIndex)
    if trialIndex == 1 then return runtime.controls.get("PriorityTrial1"):readAvailable(runtime.data) end
    if trialIndex == 2 then return runtime.controls.get("PriorityTrial2"):readAvailable(runtime.data) end
    return ""
end

function module.registerHooks(moduleRef)
    moduleRef.hooks.wrap("GetEligibleLootNames", function(host, runtime, base, excludeLootNames)
        if not host.isEnabled() then return base(excludeLootNames) end

        local state = GetRunState(runtime)
        if not state then return base(excludeLootNames) end
        state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}

        local eligible = base(excludeLootNames)
        local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
        local priorityLootKey = priorityKeyForBiome(runtime, currentBiomeIndex)
        local isPriorityMode = runtime.controls.read("PrioritizeSpecificRewardEnabled") and priorityLootKey ~= "" and
            not state.BiomePrioritySatisfied[currentBiomeIndex]

        if isPriorityMode and Contains(eligible, priorityLootKey) then
            return { priorityLootKey }
        end

        return eligible
    end)

    moduleRef.hooks.wrap("GiveLoot", function(host, runtime, base, args)
        if not host.isEnabled() then return base(args) end

        local state = GetRunState(runtime)
        if not state then return base(args) end

        local result = base(args)
        local currentBiomeIndex = CurrentRun and CurrentRun.ClearedBiomes or 0
        local lootName = args and (args.ForceLootName or args.Name)
        if runtime.controls.read("PrioritizeSpecificRewardEnabled") and
            lootName == priorityKeyForBiome(runtime, currentBiomeIndex) then
            state.BiomePrioritySatisfied[currentBiomeIndex] = true
        end
        return result
    end)

    moduleRef.hooks.wrap("SetupRoomReward", function(host, runtime, base, currentRun, room, previouslyChosenRewards, args)
        base(currentRun, room, previouslyChosenRewards, args)
        if not host.isEnabled() then return end

        local chosenRewardType = args and args.ChosenRewardType or room.ChosenRewardType
        if chosenRewardType ~= "Devotion" or not room or not room.Encounter then return end
        if not runtime.controls.read("PrioritizeTrialRewardEnabled") then return end

        local prioA = priorityKeyForTrial(runtime, 1)
        local prioB = priorityKeyForTrial(runtime, 2)
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
