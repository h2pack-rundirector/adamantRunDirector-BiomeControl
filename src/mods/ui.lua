local deps = ...
local module = {}
local resolver = deps.resolver

local UNDERWORLD_REGION = "Underworld"
local SURFACE_REGION = "Surface"

local QUICK_RESET_ALL_CONFIRM_OPTS = {
    confirmLabel = "Confirm Reset All",
}

local activeRegionTabs = {
    [UNDERWORLD_REGION] = "F",
    [SURFACE_REGION] = "O",
}

local function buildRegionTabList(region)
    local tabs = {
        { key = "NPCs", label = "NPCs" },
    }
    for _, biome in ipairs(resolver.biomes(region)) do
        tabs[#tabs + 1] = {
            key = biome.key,
            label = biome.label,
        }
    end
    return tabs
end

local uiShared = import("mods/ui/ui_shared.lua")
local regionNavOpts = {
    [UNDERWORLD_REGION] = {
        id = "BiomeControlControllerUnderworldTabs",
        navWidth = 220,
        tabs = buildRegionTabList(UNDERWORLD_REGION),
    },
    [SURFACE_REGION] = {
        id = "BiomeControlControllerSurfaceTabs",
        navWidth = 220,
        tabs = buildRegionTabList(SURFACE_REGION),
    },
}
local biomeUi = import("mods/ui/ui_biome.lua", nil, {
    uiShared = uiShared,
    resolver = resolver,
})
local npcUi = import("mods/ui/ui_npc.lua", nil, {
    uiShared = uiShared,
    resolver = resolver,
})
local dreamUi = import("mods/ui/ui_dream.lua", nil, {
    uiShared = uiShared,
})
local settingsUi = import("mods/ui/ui_settings.lua", nil, {
    uiShared = uiShared,
})

local function drawRegionTab(ui, region, childId)
    local draw = ui.draw
    local imgui = draw.imgui
    local navOpts = regionNavOpts[region]
    navOpts.activeKey = activeRegionTabs[region]
    local activeTab = draw.nav.verticalTabs(navOpts)
    activeRegionTabs[region] = activeTab

    imgui.BeginChild(childId .. "Detail", 0, 0, false)
    if activeTab == "NPCs" then
        npcUi.drawRegion(ui, region)
    else
        biomeUi.draw(ui, activeTab)
    end
    imgui.EndChild()
end

function module.drawTab(_, ui)
    local draw = ui.draw
    local imgui = draw.imgui
    if not imgui.BeginTabBar("BiomeControlControllerTabs") then
        return false
    end

    if imgui.BeginTabItem("Underworld") then
        drawRegionTab(ui, UNDERWORLD_REGION, "BiomeControlControllerUnderworld")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Surface") then
        drawRegionTab(ui, SURFACE_REGION, "BiomeControlControllerSurface")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Dream") then
        dreamUi.draw(ui)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Settings") then
        settingsUi.draw(ui)
        imgui.EndTabItem()
    end

    imgui.EndTabBar()
    return false
end

function module.drawQuickContent(_, ui)
    QUICK_RESET_ALL_CONFIRM_OPTS.action = ui.actions.get("resetAll")
    ui.draw.widgets.confirmButton("biome_control_quick_reset_all", "Reset To Default", QUICK_RESET_ALL_CONFIRM_OPTS)
end

return module
