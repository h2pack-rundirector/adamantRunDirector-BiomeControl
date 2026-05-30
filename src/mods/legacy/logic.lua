local logic = {}
local catalog
local biomeLogic
local lootLogic
local npcLogic
local dreamLogic
local RUN_STATE_CACHE = "RunState"

local function CreateStoreReader(store)
    return function(alias)
        return store.get(alias):read()
    end
end

local function GetRunState(store)
    local read = CreateStoreReader(store)
    local state = store.cache.currentRun.get(RUN_STATE_CACHE)
    if not state then return nil end
    state.BiomePrioritySatisfied = state.BiomePrioritySatisfied or {}
    state.NPCEncounterSeen = state.NPCEncounterSeen or {}
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

function logic.buildPatchPlan(host, runtime, plan)
    local store = runtime.data
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

local function createRuntimeStore(resolveRuntime)
    return {
        get = function(alias)
            return resolveRuntime().data.get(alias)
        end,
        read = function(alias, ...)
            return resolveRuntime().data.read(alias, ...)
        end,
        cache = {
            currentRun = {
                get = function(name)
                    return resolveRuntime().cache.currentRun.get(name)
                end,
            },
        },
        shared = {
            read = function(name)
                return resolveRuntime().shared.read(name)
            end,
        },
    }
end

local function createHookHost(module, resolveRuntime, setRuntime)
    local activeHost = nil
    local hookHost = {
        hooks = {},
        isEnabled = function()
            return activeHost and activeHost.isEnabled() or module.isEnabled()
        end,
        log = function(fmt, ...)
            return (activeHost or module).log(fmt, ...)
        end,
        logIf = function(fmt, ...)
            return (activeHost or module).logIf(fmt, ...)
        end,
    }

    function hookHost.hooks.wrap(path, keyOrHandler, maybeHandler)
        local key = nil
        local handler = keyOrHandler
        if maybeHandler ~= nil then
            key = keyOrHandler
            handler = maybeHandler
        end
        local function adapted(host, runtime, base, ...)
            local previousHost = activeHost
            local previousRuntime = resolveRuntime()
            activeHost = host
            setRuntime(runtime)
            local results = { pcall(handler, base, ...) }
            activeHost = previousHost
            setRuntime(previousRuntime)
            if not results[1] then
                error(results[2], 0)
            end
            return table.unpack(results, 2)
        end
        if key ~= nil then
            return module.hooks.wrap(path, key, adapted)
        end
        return module.hooks.wrap(path, adapted)
    end

    return hookHost
end

function logic.registerHooks(module)
    local currentRuntime = nil
    local function resolveRuntime()
        return currentRuntime
    end
    local function setRuntime(runtime)
        currentRuntime = runtime
    end
    local host = createHookHost(module, resolveRuntime, setRuntime)
    local store = createRuntimeStore(resolveRuntime)
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

function logic.bind(data)
    catalog = data.catalog
    local logicDeps = {
        catalog = data.catalog,
        definitions = data.definitions,
        GetRunState = GetRunState,
        CreateStoreReader = CreateStoreReader,
        godAvailability = data.godAvailability,
    }
    biomeLogic = import("mods/logic/logic_biome.lua").bind(logicDeps)
    lootLogic = import("mods/logic/logic_loot.lua").bind(logicDeps)
    npcLogic = import("mods/logic/logic_npc.lua").bind(logicDeps)
    dreamLogic = import("mods/logic/logic_dream.lua").bind(logicDeps)
    return logic
end

return logic
