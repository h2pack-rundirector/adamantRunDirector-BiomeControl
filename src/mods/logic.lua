local logic = {}
local catalog
local biomeLogic
local lootLogic
local npcLogic
local dreamLogic

local function GetRunState(host, store)
    local state = host.gameCache.currentRun.get("run", function()
        return {
            BiomePrioritySatisfied = {},
            ForcedNPCPending = {},
            NPCEncounterSeen = {},
            OnlyAllowForcedEncounters = store.read("OnlyAllowForcedEncounters"),
        }
    end)
    if not state then return nil end
    state.OnlyAllowForcedEncounters = store.read("OnlyAllowForcedEncounters")
    state.ForcedNPCPending = {}

    for _, groupKey in ipairs(catalog.npcGroups.orderedIds or {}) do
        local group = catalog.npcGroups[groupKey]
        state.ForcedNPCPending[groupKey] = {}
        for _, def in ipairs(group.definitions or {}) do
            local mode = catalog.GetModeValue(store.read, def)
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
    }
    biomeLogic = import("mods/logic/logic_biome.lua").bind(logicDeps)
    lootLogic = import("mods/logic/logic_loot.lua").bind(logicDeps)
    npcLogic = import("mods/logic/logic_npc.lua").bind(logicDeps)
    dreamLogic = import("mods/logic/logic_dream.lua").bind(logicDeps)
    return logic
end

return logic
