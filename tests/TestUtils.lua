public = {}
_PLUGIN = { guid = "test-biome-control" }

local function deepCopy(orig)
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for key, value in pairs(orig) do
        copy[key] = deepCopy(value)
    end
    return copy
end

rom = {
    mods = {},
    game = {
        DeepCopyTable = deepCopy,
        SetupRunData = function() end,
    },
    ImGui = {},
    ImGuiCol = {
        Text = 1,
    },
    gui = {
        add_to_menu_bar = function() end,
        add_imgui = function() end,
    },
}

rom.mods["SGG_Modding-ENVY"] = {
    auto = function()
        return {}
    end,
}

local function color()
    return { 255, 255, 255, 255 }
end

game = {
    Color = {
        AphroditeVoice = color(),
        ApolloVoice = color(),
        AresVoice = color(),
        DemeterVoice = color(),
        HephaestusVoice = color(),
        HeraDamage = color(),
        HestiaVoice = color(),
        PoseidonVoice = color(),
        ZeusVoice = color(),
    },
}

local function contains(list, value)
    for _, current in ipairs(list or {}) do
        if current == value then
            return true
        end
    end
    return false
end

import = function(path, fenv, ...)
    local modulePath = "src/" .. path
    local chunk = assert(loadfile(modulePath, "t", fenv or _ENV), "unable to import " .. tostring(path))
    return chunk(...)
end

local function installBaseGlobals(opts)
    opts = opts or {}

    CurrentRun = opts.CurrentRun
    rom.game.CurrentRun = CurrentRun
    GameState = opts.GameState or {}
    RewardStoreData = deepCopy(opts.RewardStoreData)
    RoomData = deepCopy(opts.RoomData or {
        F_Story01 = {
            Name = "F_Story01",
            GameStateRequirements = {
                { Path = { "CurrentRun", "BiomeDepthCache" }, Comparison = ">=", Value = 4 },
                { Path = { "CurrentRun", "BiomeDepthCache" }, Comparison = "<=", Value = 8 },
            },
        },
        F_MiniBoss01 = {
            Name = "F_MiniBoss01",
            GameStateRequirements = {},
        },
        H_MiniBoss01 = {
            Name = "H_MiniBoss01",
            GameStateRequirements = {},
        },
        H_MiniBoss02 = {
            Name = "H_MiniBoss02",
            GameStateRequirements = {},
        },
    })
    RoomSetData = deepCopy(opts.RoomSetData or {
        F = {
            F_Combat05 = { Name = "F_Combat05" },
        },
    })
    NamedRequirementsData = deepCopy(opts.NamedRequirementsData or {
        NoRecentFieldNPCEncounter = {
            { SumPrevRooms = 6 },
        },
    })
    EncounterData = deepCopy(opts.EncounterData or {
        ArtemisCombatF = {},
        ArtemisCombatG = {},
        NemesisCombatF = {},
    })

    Contains = contains
    GetEligibleLootNames = opts.GetEligibleLootNames or function()
        return { "ZeusUpgrade", "ApolloUpgrade" }
    end
    GiveLoot = opts.GiveLoot or function(args)
        return args
    end
    SetupRoomReward = opts.SetupRoomReward or function() end
    ChooseEncounter = opts.ChooseEncounter or function(_, _, args)
        return args
    end
    SelectNextDreamBiome = opts.SelectNextDreamBiome or function()
        return "base"
    end
    SelectFieldsDoorCageCount = opts.SelectFieldsDoorCageCount or function()
        return 3
    end
    GetInteractedGodsThisRun = opts.GetInteractedGodsThisRun or function()
        return {}
    end
    IsGameStateEligible = opts.IsGameStateEligible or function()
        return true
    end
    IsEncounterEligible = opts.IsEncounterEligible or function()
        return true
    end
end

local function controlValue(values, name, key, fallback)
    local value = values[name]
    if type(value) == "table" then
        if value[key] ~= nil then
            return value[key]
        end
        local lowerKey = key:sub(1, 1):lower() .. key:sub(2)
        if value[lowerKey] ~= nil then
            return value[lowerKey]
        end
    elseif key == "Value" and value ~= nil then
        return value
    end
    return fallback
end

local function makeControl(name, definition, values)
    definition = definition or {}
    local template = definition.template

    local control = {}

    function control.read()
        if template == "Flag" then
            return controlValue(values, name, "Value", definition.default == true) == true
        end
        if template == "Choice" or template == "GodChoice" then
            return controlValue(values, name, "Value", definition.default or "")
        end
        if template == "PackedSet" then
            return controlValue(values, name, "Value", definition.default or 0)
        end
        if template == "Mode" then
            return control:mode()
        end
        if template == "ModeWithRange" then
            local minValue, maxValue = control:range()
            return {
                mode = control:mode(),
                min = minValue,
                max = maxValue,
            }
        end
        return controlValue(values, name, "Value", definition.default)
    end

    function control.mode()
        return controlValue(values, name, "Mode", definition.default or "default")
    end

    function control.range()
        local range = definition.range or {}
        local minValue = controlValue(values, name, "Min", range.defaultMin or range.min or 0)
        local maxValue = controlValue(values, name, "Max", range.defaultMax or range.max or minValue)
        return minValue, maxValue
    end

    function control.readAvailable(_, availableGods)
        local value = control.read()
        if value == nil or value == "" then
            return ""
        end
        local godKey = definition.godKeyByValue and definition.godKeyByValue[value] or nil
        if godKey ~= nil and availableGods ~= nil and availableGods[godKey] == false then
            return definition.default or ""
        end
        return value
    end

    function control.mask()
        return controlValue(values, name, "Value", definition.default or 0)
    end

    function control.options()
        return definition.options or {}
    end

    function control.route()
        if controlValue(values, name, "Enabled", definition.defaultEnabled == true) ~= true then
            return nil
        end
        return {
            controlValue(values, name, "Biome1", definition.defaults and definition.defaults[1] or "G"),
            controlValue(values, name, "Biome2", definition.defaults and definition.defaults[2] or "I"),
            controlValue(values, name, "Biome3", definition.defaults and definition.defaults[3] or "N"),
            controlValue(values, name, "Biome4", definition.defaults and definition.defaults[4] or "P"),
        }
    end

    function control.biomeAt(_, index)
        local route = control.route()
        return route and route[math.floor(tonumber(index) or 0)] or nil
    end

    function control.isNaturalNext(_, current, nextValue)
        return current ~= nil and definition.naturalNextBiome and definition.naturalNextBiome[current] == nextValue
    end

    return control
end

local function makeControls(definitions, fixtures)
    fixtures = fixtures or {}
    local controls = {}
    local api = {}

    function api.get(name)
        if controls[name] == nil then
            controls[name] = makeControl(name, definitions[name], fixtures)
        end
        return controls[name]
    end

    function api.read(name)
        return api.get(name).read()
    end

    return api
end

local function makeRuntime(controlDefinitions, controlFixtures, godAvailability)
    local state = {
        BiomePrioritySatisfied = {},
        ForcedNPCPending = {},
        NPCEncounterSeen = {},
    }
    local controls = makeControls(controlDefinitions, controlFixtures)
    local snapshot = {
        active = godAvailability and godAvailability.active ~= false or godAvailability ~= nil,
        available = godAvailability and godAvailability.available or {},
    }

    local runtime = {
        controls = controls,
        data = {
            cache = {
                currentRun = {
                    get = function()
                        return state
                    end,
                },
            },
            shared = {
                read = function(name)
                    if name == "GodAvailability" then
                        return snapshot
                    end
                    return nil
                end,
            },
        },
    }

    return runtime, state
end

local function makeHost()
    return {
        isEnabled = function()
            return true
        end,
        logIf = function() end,
    }
end

local function makeHookHost()
    local wraps = {}
    return {
        wraps = wraps,
        hooks = {
            wrap = function(name, keyOrCallback, maybeCallback)
                wraps[name] = maybeCallback or keyOrCallback
                local callback = wraps[name]
                local base = _G[name]
                _G[name] = function(...)
                    return callback(makeHost(), _G.__BiomeControlRuntime, base, ...)
                end
            end,
        },
    }
end

function MakeBiomeControlPlan()
    local plan = {}

    function plan:set(target, key, value)
        target[key] = value
    end

    function plan:setMany(target, fields)
        for key, value in pairs(fields) do
            target[key] = value
        end
    end

    function plan:appendUnique(target, key, value)
        local list = target[key]
        if type(list) ~= "table" then
            list = {}
            target[key] = list
        end
        for _, existing in ipairs(list) do
            if existing == value then
                return
            end
        end
        table.insert(list, value)
    end

    function plan:transform(target, key, callback)
        target[key] = callback(target[key])
    end

    function plan:setElement(target, key, current, replacement)
        local list = target[key]
        for index, value in ipairs(list or {}) do
            if value == current then
                list[index] = replacement
                return
            end
        end
    end

    return plan
end

function ResetBiomeControlHarness(opts)
    opts = opts or {}
    installBaseGlobals(opts)

    local data = dofile("src/mods/data.lua")
    local godAvailability = dofile("src/mods/shared/god_availability.lua")
    local logic = import("mods/logic.lua", nil, {
        godAvailability = godAvailability,
        resolver = data.resolver,
    })
    local runtime, state = makeRuntime(data.buildControls(), opts.controls, opts.godAvailability)
    local host = makeHost()

    local hookHost = makeHookHost()
    logic.attachHooks(hookHost)
    __BiomeControlRuntime = runtime

    local mutationPatch = nil
    logic.attachMutations({
        mutation = {
            patch = function(callback)
                mutationPatch = callback
            end,
        },
    })

    local harness = {
        data = data,
        logic = logic,
        host = host,
        runtime = runtime,
        state = state,
        hookHandlers = hookHost.wraps,
        buildPatchPlan = mutationPatch,
    }

    function harness.applyPatchPlan()
        local plan = MakeBiomeControlPlan()
        mutationPatch(host, runtime, plan)
        return plan
    end

    return harness
end
