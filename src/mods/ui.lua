local module = {}
local definitions = nil
local catalog = nil
local biomeUi = nil
local npcUi = nil
local dreamUi = nil
local settingsUi = nil
local regionNavOpts = nil

local UNDERWORLD_REGION = "Underworld"
local SURFACE_REGION = "Surface"
local UNDERWORLD_TAB_ALIAS = "UnderworldTab"
local SURFACE_TAB_ALIAS = "SurfaceTab"

local function BuildRegionTabList(region)
    local tabs = {
        { key = "NPCs", label = "NPCs" },
    }
    for _, biome in ipairs(catalog.biomeTabs or {}) do
        if biome.region == region then
            tabs[#tabs + 1] = {
                key = biome.key,
                label = biome.label,
            }
        end
    end
    return tabs
end

local function DrawRegionTab(draw, state, region, tabAlias, childId)
    local imgui = draw.imgui
    local tabField = state.get(tabAlias)
    local navOpts = regionNavOpts[region]
    navOpts.activeKey = tabField:read()
    local activeTab = draw.nav.verticalTabs(navOpts)
    if activeTab ~= tabField:read() then
        tabField:write(activeTab)
    end

    imgui.BeginChild(childId .. "Detail", 0, 0, false)
    if activeTab == "NPCs" then
        npcUi.drawRegion(draw, state, region)
    else
        biomeUi.draw(draw, state, activeTab)
    end
    imgui.EndChild()
end

function module.drawTab(draw, state, _, services)
    local imgui = draw.imgui
    if not imgui.BeginTabBar("BiomeControlLeanTabs") then
        return false
    end

    if imgui.BeginTabItem("Underworld") then
        DrawRegionTab(draw, state, UNDERWORLD_REGION, UNDERWORLD_TAB_ALIAS, "BiomeControlUnderworld")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Surface") then
        DrawRegionTab(draw, state, SURFACE_REGION, SURFACE_TAB_ALIAS, "BiomeControlSurface")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Dream") then
        dreamUi.draw(draw, state)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Settings") then
        settingsUi.draw(draw, state, services)
        imgui.EndTabItem()
    end

    imgui.EndTabBar()
    return false
end

function module.drawQuickContent(draw, state)
    draw.widgets.confirmButton("biome_control_quick_reset_all", "Reset To Default", {
        confirmLabel = "Confirm Reset All",
        onConfirm = function()
            state.resetAll()
        end,
    })
end

function module.bind(state)
    local components = import("mods/ui/ui_components.lua")
    definitions = state.definitions
    catalog = state.catalog
    regionNavOpts = {
        [UNDERWORLD_REGION] = {
            id = "BiomeControlUnderworldTabs",
            navWidth = 220,
            tabs = BuildRegionTabList(UNDERWORLD_REGION),
        },
        [SURFACE_REGION] = {
            id = "BiomeControlSurfaceTabs",
            navWidth = 220,
            tabs = BuildRegionTabList(SURFACE_REGION),
        },
    }
    biomeUi = import("mods/ui/ui_biome.lua").bind({
        definitions = definitions,
        catalog = catalog,
        components = components,
    })
    npcUi = import("mods/ui/ui_npc.lua").bind({
        definitions = definitions,
        catalog = catalog,
        components = components,
    })
    dreamUi = import("mods/ui/ui_dream.lua").bind({
        definitions = definitions,
        catalog = catalog,
        components = components,
    })
    settingsUi = import("mods/ui/ui_settings.lua").bind({
        definitions = definitions,
        components = components,
        godAvailability = state.godAvailability,
    })
    return module
end

return module
