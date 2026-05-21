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

local function DrawRegionTab(draw, data, region, tabAlias, childId)
    local imgui = draw.imgui
    local tabField = data.get(tabAlias)
    local tabs = BuildRegionTabList(region)
    local activeTab = draw.nav.verticalTabs({
        id = childId .. "Tabs",
        navWidth = 220,
        tabs = tabs,
        activeKey = tabField:read(),
    })
    if activeTab ~= tabField:read() then
        tabField:write(activeTab)
    end

    imgui.BeginChild(childId .. "Detail", 0, 0, false)
    if activeTab == "NPCs" then
        npcUi.drawRegion(draw, data, region)
    else
        biomeUi.draw(draw, data, activeTab)
    end
    imgui.EndChild()
end

function module.drawTab(draw, data, _, services)
    local imgui = draw.imgui
    if not imgui.BeginTabBar("BiomeControlLeanTabs") then
        return false
    end

    if imgui.BeginTabItem("Underworld") then
        DrawRegionTab(draw, data, UNDERWORLD_REGION, UNDERWORLD_TAB_ALIAS, "BiomeControlUnderworld")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Surface") then
        DrawRegionTab(draw, data, SURFACE_REGION, SURFACE_TAB_ALIAS, "BiomeControlSurface")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Dream") then
        dreamUi.draw(draw, data)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Settings") then
        settingsUi.draw(draw, data, services)
        imgui.EndTabItem()
    end

    imgui.EndTabBar()
    return false
end

function module.drawQuickContent(draw, data)
    draw.widgets.confirmButton("biome_control_quick_reset_all", "Reset To Default", {
        confirmLabel = "Confirm Reset All",
        onConfirm = function()
            data.resetToDefaults()
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
