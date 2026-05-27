local deps = ...
local module = {}
local definitions = deps.definitions
local catalog = deps.catalog

local UNDERWORLD_REGION = "Underworld"
local SURFACE_REGION = "Surface"
local UNDERWORLD_TAB_ALIAS = "UnderworldTab"
local SURFACE_TAB_ALIAS = "SurfaceTab"

local QUICK_RESET_ALL_CONFIRM_OPTS = {
    confirmLabel = "Confirm Reset All",
}

local function buildRegionTabList(region)
    local tabs = {
        { key = "NPCs", label = "NPCs" },
    }
    for _, biome in ipairs(catalog.biomes.ordered or {}) do
        if biome.region == region then
            tabs[#tabs + 1] = {
                key = biome.key,
                label = biome.label,
            }
        end
    end
    return tabs
end

local components = import("mods/ui3/controllers/init.lua", nil, {
    components = import("mods/ui3/components.lua"),
})
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
local biomeUi = import("mods/ui3/ui_biome.lua", nil, {
    catalog = catalog,
    components = components,
})
local npcUi = import("mods/ui3/ui_npc.lua", nil, {
    catalog = catalog,
    components = components,
})
local dreamUi = import("mods/ui3/ui_dream.lua", nil, {
    definitions = definitions,
    catalog = catalog,
    components = components,
})
local settingsUi = import("mods/ui3/ui_settings.lua", nil, {
    definitions = definitions,
    components = components,
    godAvailability = deps.godAvailability,
})

local function drawRegionTab(draw, state, region, tabAlias, childId)
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

function module.drawTab(draw, state, actions)
    local imgui = draw.imgui
    if not imgui.BeginTabBar("BiomeControlControllerTabs") then
        return false
    end

    if imgui.BeginTabItem("Underworld") then
        drawRegionTab(draw, state, UNDERWORLD_REGION, UNDERWORLD_TAB_ALIAS, "BiomeControlControllerUnderworld")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Surface") then
        drawRegionTab(draw, state, SURFACE_REGION, SURFACE_TAB_ALIAS, "BiomeControlControllerSurface")
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Dream") then
        dreamUi.draw(draw, state)
        imgui.EndTabItem()
    end

    if imgui.BeginTabItem("Settings") then
        settingsUi.draw(draw, state, actions)
        imgui.EndTabItem()
    end

    imgui.EndTabBar()
    return false
end

function module.drawQuickContent(draw, _, actions)
    QUICK_RESET_ALL_CONFIRM_OPTS.action = actions.get("resetAll")
    draw.widgets.confirmButton("biome_control_quick_reset_all", "Reset To Default", QUICK_RESET_ALL_CONFIRM_OPTS)
end

return module
