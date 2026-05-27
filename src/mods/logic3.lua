local data = ...
local logic = {}

local catalog = data.catalog
local RUN_STATE_CACHE = "RunState"

local function createStoreReader(store)
    return function(alias)
        return store.get(alias):read()
    end
end

local controllerReader = import("mods/logic3/controller_reader.lua")

local logicDeps = {
    catalog = catalog,
    definitions = data.definitions,
    controllerReader = controllerReader,
    CreateStoreReader = createStoreReader,
    godAvailability = data.godAvailability,
}

local function getRunState(store)
    local state = store.cache.currentRun.get(RUN_STATE_CACHE)
    if not state then return nil end
    state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}
    state.NPCEncounterSeen = state.NPCEncounterSeen or {}
    state.OnlyAllowForcedEncounters = store.read("OnlyAllowForcedEncounters")
    state.ForcedNPCPending = {}

    for _, groupKey in ipairs(catalog.npcs.orderedIds or {}) do
        local group = catalog.npcs[groupKey]
        state.ForcedNPCPending[groupKey] = {}
        for _, def in ipairs(group.definitions or {}) do
            local mode = controllerReader.readMode(store, def.controller)
            if mode == "forced" then
                state.ForcedNPCPending[groupKey][def.biome] = true
            end
        end
    end

    return state
end

logicDeps.GetRunState = getRunState

local biomeLogic = import("mods/logic3/logic_biome.lua", nil, logicDeps)
local lootLogic = import("mods/logic3/logic_loot.lua", nil, logicDeps)
local npcLogic = import("mods/logic3/logic_npc.lua", nil, logicDeps)
local dreamLogic = import("mods/logic3/logic_dream.lua", nil, logicDeps)

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

function logic.buildCacheDeclarations()
    return {
        [RUN_STATE_CACHE] = {
            domain = "currentRun",
            key = "run",
            factory = function()
                return {
                    BiomePrioritySatisfied = {},
                    ForcedNPCPending = {},
                    NPCEncounterSeen = {},
                }
            end,
        },
    }
end

return logic
