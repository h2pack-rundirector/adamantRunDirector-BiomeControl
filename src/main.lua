local mods = rom.mods
mods["SGG_Modding-ENVY"].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods["SGG_Modding-ModUtil"]
local reload = mods["SGG_Modding-ReLoad"]
---@module "adamant-ModpackLib"
---@type AdamantModpackLib
lib = mods["adamant-ModpackLib"]

local PACK_ID = "run-director"
local MODULE_ID = "BiomeControl"
local PLUGIN_GUID = _PLUGIN.guid

local function init()
    import_as_fallback(rom.game)
    local data = import("mods/data.lua")
    local godAvailability = import("mods/shared/god_availability.lua")
    local deps = {
        godAvailability = godAvailability,
        resolver = data.resolver,
    }
    local logic = import("mods/logic.lua", nil, deps)
    local ui = import("mods/ui.lua", nil, deps)

    local module = lib.createModule({
        pluginGuid = PLUGIN_GUID,
        modpack = PACK_ID,
        id = MODULE_ID,
        name = "Biome Control",
        tooltip = "Control biome rooms, NPC encounters, rewards, and biome-specific tweaks.",
    })
    if not module then
        return
    end

    module.data.define(data.buildStorage())
    module.controls.defineTemplates(data.buildControlTemplates())
    module.controls.define(data.buildControls())

    godAvailability.attach(module)

    logic.defineCache(module)
    logic.attachMutations(module)
    logic.attachHooks(module)

    ui.attach(module)

    module.fallbackUi.attachGuiOnce(function(fallbackUi)
        rom.gui.add_imgui(fallbackUi.renderWindow)
        rom.gui.add_to_menu_bar(fallbackUi.addMenuBar)
    end)
    local ok = module.activate()
    if not ok then
        return
    end
end

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(nil, init)
end)
