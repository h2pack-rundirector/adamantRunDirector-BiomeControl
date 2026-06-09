local deps = ...
local module = {}
local getRunState = deps.getRunState
local godAvailability = deps.godAvailability

local function priorityKeyForBiome(runtime, biomeIndex)
    biomeIndex = math.max((biomeIndex or 0) - 1, 0)
    local availableGods = godAvailability.availableGods(runtime.data)
    if biomeIndex == 0 then return runtime.controls.get("PriorityBiome1"):readAvailable(availableGods) end
    if biomeIndex == 1 then return runtime.controls.get("PriorityBiome2"):readAvailable(availableGods) end
    if biomeIndex == 2 then return runtime.controls.get("PriorityBiome3"):readAvailable(availableGods) end
    if biomeIndex == 3 then return runtime.controls.get("PriorityBiome4"):readAvailable(availableGods) end
    return ""
end

local function priorityKeyForTrial(runtime, trialIndex)
    local availableGods = godAvailability.availableGods(runtime.data)
    if trialIndex == 1 then return runtime.controls.get("PriorityTrial1"):readAvailable(availableGods) end
    if trialIndex == 2 then return runtime.controls.get("PriorityTrial2"):readAvailable(availableGods) end
    return ""
end

local function currentBiomeIndex()
    return CurrentRun and CurrentRun.EnteredBiomes or 0
end

local bypassBiomePriorityDepth = 0

local function withBiomePriorityBypassed(callback)
    bypassBiomePriorityDepth = bypassBiomePriorityDepth + 1
    local ok, result = pcall(callback)
    bypassBiomePriorityDepth = bypassBiomePriorityDepth - 1
    if not ok then error(result, 0) end
    return result
end

function module.registerHooks(moduleRef)
    moduleRef.hooks.wrap("GetEligibleLootNames", function(host, runtime, base, excludeLootNames)
        if not host.isEnabled() then return base(excludeLootNames) end
        if bypassBiomePriorityDepth > 0 then return base(excludeLootNames) end

        local state = getRunState(runtime)
        if not state then return base(excludeLootNames) end
        state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}

        local eligible = base(excludeLootNames)
        local biomeIndex = currentBiomeIndex()
        local priorityLootKey = priorityKeyForBiome(runtime, biomeIndex)
        local isPriorityMode = runtime.controls.read("PrioritizeSpecificRewardEnabled") and priorityLootKey ~= "" and
            not state.BiomePrioritySatisfied[biomeIndex]

        if isPriorityMode and Contains(eligible, priorityLootKey) then
            return { priorityLootKey }
        end

        return eligible
    end)

    moduleRef.hooks.wrap("GiveLoot", function(host, runtime, base, args)
        if not host.isEnabled() then return base(args) end

        local state = getRunState(runtime)
        if not state then return base(args) end

        local result = base(args)
        local biomeIndex = currentBiomeIndex()
        local lootName = args and (args.ForceLootName or args.Name)
        if runtime.controls.read("PrioritizeSpecificRewardEnabled") and
            lootName == priorityKeyForBiome(runtime, biomeIndex) then
            state.BiomePrioritySatisfied[biomeIndex] = true
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
            withBiomePriorityBypassed(function()
                return Contains(GetEligibleLootNames(), prioA) and
                    Contains(GetEligibleLootNames({ prioA }), prioB)
            end) then
            room.Encounter.LootAName = prioA
            room.Encounter.LootBName = prioB
        end
    end)
end

return module
