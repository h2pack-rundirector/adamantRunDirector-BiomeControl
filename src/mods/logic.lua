local deps = ...
local logic = {}

local resolver = deps.resolver
local RUN_STATE_CACHE = "RunState"

local logicDeps = {
    godAvailability = deps.godAvailability,
    resolver = resolver,
}

local function getRunState(runtime)
    local state = runtime.data.cache.currentRun.get(RUN_STATE_CACHE)
    if not state then return nil end
    state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}
    state.NPCEncounterSeen = state.NPCEncounterSeen or {}
    state.OnlyAllowForcedEncounters = runtime.controls.read("OnlyAllowForcedEncounters")
    state.ForcedNPCPending = {}

    for _, group in ipairs(resolver.npcGroups()) do
        state.ForcedNPCPending[group.id] = {}
        for _, def in ipairs(group.entries or {}) do
            local mode = runtime.controls.get(def.controlName):mode()
            if mode == "forced" then
                state.ForcedNPCPending[group.id][def.biome] = true
            end
        end
    end

    return state
end

logicDeps.getRunState = getRunState

local biomeLogic = import("mods/logic/logic_biome.lua", nil, logicDeps)
local lootLogic = import("mods/logic/logic_loot.lua", nil, logicDeps)
local npcLogic = import("mods/logic/logic_npc.lua", nil, logicDeps)
local dreamLogic = import("mods/logic/logic_dream.lua", nil, logicDeps)

local function buildPatchPlan(host, runtime, plan)
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

function logic.attachMutations(module)
    module.mutation.patch(buildPatchPlan)
end

function logic.attachHooks(module)
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

function logic.defineCache(module)
    module.cache.define({
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
    })
end

return logic
