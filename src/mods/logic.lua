local logic = {}
local catalog
local biomeLogic
local lootLogic
local npcLogic
local dreamLogic

local function CreateStoreReader(store)
    return function(alias)
        return store.get(alias):read()
    end
end

local function GetRunState(host, store)
    local read = CreateStoreReader(store)
    local state = host.cache.currentRun.get("run", function()
        return {
            BiomePrioritySatisfied = {},
            ForcedNPCPending = {},
            NPCEncounterSeen = {},
            OnlyAllowForcedEncounters = read("OnlyAllowForcedEncounters"),
        }
    end)
    if not state then return nil end
    state.OnlyAllowForcedEncounters = read("OnlyAllowForcedEncounters")
    state.ForcedNPCPending = {}

    for _, groupKey in ipairs(catalog.npcGroups.orderedIds or {}) do
        local group = catalog.npcGroups[groupKey]
        state.ForcedNPCPending[groupKey] = {}
        for _, def in ipairs(group.definitions or {}) do
            local mode = catalog.GetModeValue(read, def)
            if mode == "forced" then
                state.ForcedNPCPending[groupKey][def.biome] = true
            end
        end
    end

    return state
end

function logic.buildPatchPlan(plan, host, store)
    if biomeLogic.buildPatchPlan then
        biomeLogic.buildPatchPlan(plan, host, store)
    end
    if lootLogic.buildPatchPlan then
        lootLogic.buildPatchPlan(plan, host, store)
    end
    if npcLogic.buildPatchPlan then
        npcLogic.buildPatchPlan(plan, host, store)
    end
end

function logic.registerHooks(host, store)
    if biomeLogic.registerHooks then
        biomeLogic.registerHooks(host, store)
    end
    if lootLogic.registerHooks then
        lootLogic.registerHooks(host, store)
    end
    if npcLogic.registerHooks then
        npcLogic.registerHooks(host, store)
    end
    if dreamLogic.registerHooks then
        dreamLogic.registerHooks(host, store)
    end
end

function logic.bind(data)
    catalog = data.catalog
    local logicDeps = {
        catalog = data.catalog,
        definitions = data.definitions,
        GetRunState = GetRunState,
        CreateStoreReader = CreateStoreReader,
    }
    biomeLogic = import("mods/logic/logic_biome.lua").bind(logicDeps)
    lootLogic = import("mods/logic/logic_loot.lua").bind(logicDeps)
    npcLogic = import("mods/logic/logic_npc.lua").bind(logicDeps)
    dreamLogic = import("mods/logic/logic_dream.lua").bind(logicDeps)
    return logic
end

return logic
