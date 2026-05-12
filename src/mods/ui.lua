local module = {}
local definitions = nil
local catalog = nil
local biomeUi = nil
local npcUi = nil
local dreamUi = nil
local settingsUi = nil

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

local function DrawRegionTab(imgui, session, region, tabAlias, childId)
    local tabs = BuildRegionTabList(region)
    local activeTab = lib.nav.verticalTabs(imgui, {
        id = childId .. "Tabs",
        navWidth = 220,
        tabs = tabs,
        activeKey = session.view[tabAlias],
    })
    if activeTab ~= session.view[tabAlias] then
        session.write(tabAlias, activeTab)
    end

    imgui.BeginChild(childId .. "Detail", 0, 0, false)
    if activeTab == "NPCs" then
        npcUi.drawRegion(imgui, session, region)
    else
        biomeUi.draw(imgui, session, activeTab)
    end
    imgui.EndChild()
end

function module.drawTab(imgui, session)
    if not imgui.BeginTabBar("BiomeControlLeanTabs") then
        return false
    end

    if imgui.BeginTabItem("Underworld") then
        DrawRegionTab(imgui, session, UNDERWORLD_REGION, UNDERWORLD_TAB_ALIAS, "BiomeControlUnderworld")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Surface") then
        DrawRegionTab(imgui, session, SURFACE_REGION, SURFACE_TAB_ALIAS, "BiomeControlSurface")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Dream") then
        dreamUi.draw(imgui, session)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Settings") then
        settingsUi.draw(imgui, session)
        imgui.EndTabItem()
    end

    imgui.EndTabBar()
    return false
end

function module.drawQuickContent(imgui, session)
    lib.widgets.confirmButton(imgui, "biome_control_quick_reset_all", "Reset To Default", {
        confirmLabel = "Confirm Reset All",
        onConfirm = function()
            session.resetToDefaults()
        end,
    })
end

function module.bind(data)
    local components = import("mods/ui/ui_components.lua")
    definitions = data.definitions
    catalog = data.catalog
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
    })
    return module
end

return module
