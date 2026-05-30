local data = ...
local logic = {}

local catalog = data.catalog
local RUN_STATE_CACHE = "RunState"

local logicDeps = {
    catalog = catalog,
    definitions = data.definitions,
    godAvailability = data.godAvailability,
}

local function getRunState(runtime)
    local state = runtime.data.cache.currentRun.get(RUN_STATE_CACHE)
    if not state then return nil end
    state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}
    state.NPCEncounterSeen = state.NPCEncounterSeen or {}
    state.OnlyAllowForcedEncounters = runtime.controls.read("OnlyAllowForcedEncounters")
    state.ForcedNPCPending = {}

    for _, groupKey in ipairs(catalog.npcs.orderedIds or {}) do
        local group = catalog.npcs[groupKey]
        state.ForcedNPCPending[groupKey] = {}
        for _, def in ipairs(group.definitions or {}) do
            local mode = runtime.controls.get(def.setting.name):mode()
            if mode == "forced" then
                state.ForcedNPCPending[groupKey][def.biome] = true
            end
        end
    end

    return state
end

logicDeps.GetRunState = getRunState

local biomeLogic = import("mods/logic/logic_biome.lua", nil, logicDeps)
local lootLogic = import("mods/logic/logic_loot.lua", nil, logicDeps)
local npcLogic = import("mods/logic/logic_npc.lua", nil, logicDeps)
local dreamLogic = import("mods/logic/logic_dream.lua", nil, logicDeps)

function logic.buildPatchPlan(host, runtime, plan)
    if biomeLogic.buildPatchPlan then
        biomeLogic.buildPatchPlan(host, runtime, plan)
    end
    if lootLogic.buildPatchPlan then
        lootLogic.buildPatchPlan(host, runtime, plan)
    end
    if npcLogic.buildPatchPlan then
        npcLogic.buildPatchPlan(host, runtime, plan)
    end
end

function logic.registerHooks(module)
    if biomeLogic.registerHooks then
        biomeLogic.registerHooks(module)
    end
    if lootLogic.registerHooks then
        lootLogic.registerHooks(module)
    end
    if npcLogic.registerHooks then
        npcLogic.registerHooks(module)
    end
    if dreamLogic.registerHooks then
        dreamLogic.registerHooks(module)
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
