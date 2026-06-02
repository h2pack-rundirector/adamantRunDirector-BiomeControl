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

rom.mods["SGG_Modding-Chalk"] = {
    auto = function()
        return { DebugMode = false }
    end,
    original = function(config)
        return config
    end,
}

local registeredWraps = {}

local modUtilApi = {
    Path = {
        Wrap = function(path, handler)
            registeredWraps[path] = handler
            local base = _G[path]
            _G[path] = function(...)
                return handler(base, ...)
            end
        end,
    },
}
modutil = {
    globals = _G,
    mod = modUtilApi,
    once_loaded = {
        game = function() end,
    },
}
modutil.globals.ModUtil = modUtilApi
ModUtil = modUtilApi
rom.mods["SGG_Modding-ModUtil"] = modutil

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
    local libPath = "../../adamant-ModpackLib/src/" .. path
    local modulePath = "src/" .. path
    local chunk = loadfile(libPath, "t", fenv or _ENV) or loadfile(modulePath, "t", fenv or _ENV)
    return assert(chunk, "unable to import " .. tostring(path))(...)
end

dofile("../../adamant-ModpackLib/src/main.lua")
lib = public
rom.mods["adamant-ModpackLib"] = lib

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

local function applyOverrides(target, overrides)
    for key, value in pairs(overrides or {}) do
        target[key] = value
    end
end

local function normalizeControlFieldKey(key)
    if key == "mode" then return "Mode" end
    if key == "min" then return "Min" end
    if key == "max" then return "Max" end
    if key == "value" then return "Value" end
    return key
end

local function writeControlValue(control, key, value)
    local normalizedKey = normalizeControlFieldKey(key)
    if normalizedKey == "Mode" and type(control.writeMode) == "function" then
        return control:writeMode(value)
    end
    if normalizedKey == "Value" and type(control.write) == "function" then
        return control:write(value)
    end
    if type(control.field) ~= "function" then
        error("control does not expose field access", 2)
    end

    local field = normalizedKey == "Value" and control:field() or control:field(normalizedKey)
    if field == nil or type(field.write) ~= "function" then
        error("control field '" .. tostring(normalizedKey) .. "' is not writable", 2)
    end
    return field:write(value)
end

local function applyControlFixtures(ui, fixtures)
    for name, values in pairs(fixtures or {}) do
        local control = ui.controls.get(name)
        if type(values) == "table" then
            for key, value in pairs(values) do
                writeControlValue(control, key, value)
            end
        else
            writeControlValue(control, "Value", values)
        end
    end
end

local function getLiveStore(liveHost)
    local registry = AdamantModpackLib_Runtime and AdamantModpackLib_Runtime.registry
    local modules = registry and registry.modules
    local records = modules and modules.records
    local record = records and records[liveHost]
    return record and record.store or nil
end

local function publishGodAvailability(pluginGuid, godAvailability)
    local module = lib.createModule({
        pluginGuid = pluginGuid .. ":god-availability-provider",
        config = {
            Enabled = not godAvailability or godAvailability.active ~= false,
        },
        modpack = "run-director",
        id = "TestGodPoolProvider",
        name = "Test God Pool Provider",
    })

    if godAvailability then
        local available = {}
        for godKey, value in pairs(godAvailability.available or {}) do
            available[godKey] = value ~= false
        end
        module.shared.data.owner("GodAvailability", {
            id = "run-director.god-availability",
            default = {
                active = godAvailability.active ~= false,
                available = available,
            },
        })
    end
    module.ui.tab(function() end)
    module.activate()
end

function ResetBiomeControlHarness(opts)
    opts = opts or {}
    local pluginGuid = opts.pluginGuid or "adamant-RunDirector_BiomeControl:test"
    registeredWraps = {}
    installBaseGlobals(opts)

    local data = dofile("src/mods/data.lua")
    local godAvailability = dofile("src/mods/shared/god_availability.lua")
    local logic = import("mods/logic.lua", nil, {
        godAvailability = godAvailability,
        resolver = data.resolver,
    })

    local config = dofile("src/config.lua")
    applyOverrides(config, opts.config)

    local module = lib.createModule({
        pluginGuid = pluginGuid,
        config = config,
        modpack = "run-director",
        id = "BiomeControl",
        name = "Biome Control",
    })
    module.data.define(data.buildStorage())
    module.controls.defineTemplates(data.buildControlTemplates())
    module.controls.define(data.buildControls())
    logic.defineCache(module)
    local pendingControlFixtures = opts.controls
    module.ui.tab(function(_, ui)
        if pendingControlFixtures ~= nil then
            applyControlFixtures(ui, pendingControlFixtures)
            pendingControlFixtures = nil
        end
    end)
    logic.attachMutations(module)
    godAvailability.attach(module)
    if opts.registerHooks then
        logic.attachHooks(module)
    end
    module.activate()
    publishGodAvailability(pluginGuid, opts.godAvailability)

    local liveHost = lib.createFrameworkRuntime("adamant-ModpackFramework").modules.getLiveHost(pluginGuid)
    local store = getLiveStore(liveHost)
    if opts.controls ~= nil then
        liveHost.drawTab()
        liveHost.flush()
    end

    return {
        data = data,
        logic = logic,
        config = config,
        store = store,
        liveHost = liveHost,
        wrappers = registeredWraps,
    }
end
