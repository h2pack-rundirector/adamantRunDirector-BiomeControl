local deps = ...
local module = {}
local catalog = deps.catalog
local components = deps.components

local NPC_HEADING_COLOR = { 0.90, 0.82, 0.56, 1.0 }
local NPC_RULES_HEADING_COLOR = { 0.70, 0.84, 0.96, 1.0 }
local NPC_GROUP_COLORS = {
    Artemis = { 15 / 255, 255 / 255, 9 / 255, 1.0 },
    Nemesis = { 115 / 255, 146 / 255, 210 / 255, 1.0 },
    Athena = { 255 / 255, 216 / 255, 60 / 255, 1.0 },
    Heracles = { 255 / 255, 125 / 255, 25 / 255, 1.0 },
    Icarus = { 243 / 255, 215 / 255, 116 / 255, 1.0 },
}
local DEFAULT_NPC_GROUP_TEXT_OPTS = {
    color = { 0.90, 0.82, 0.56, 1.0 },
}
local NPC_GROUP_TEXT_OPTS = {
    Artemis = { color = NPC_GROUP_COLORS.Artemis },
    Nemesis = { color = NPC_GROUP_COLORS.Nemesis },
    Athena = { color = NPC_GROUP_COLORS.Athena },
    Heracles = { color = NPC_GROUP_COLORS.Heracles },
    Icarus = { color = NPC_GROUP_COLORS.Icarus },
}
local ONLY_ALLOW_FORCED_ENCOUNTERS_OPTS = {
    label = "Only Allow Forced NPC Encounters",
    tooltip = "Blocks NPC encounters left on Default. Only Forced entries can appear.",
}
local IGNORE_MAX_DEPTH_OPTS = {
    label = "Ignore NPC Max Depth Requirements",
    tooltip = "Forced NPC encounters can still appear after max depth.",
}
local NPC_SPACING_OPTS = {
    label = "Minimum rooms between field NPC encounters",
    values = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 },
    controlWidth = 60,
}
local NPC_RULE_HELP_TEXT_OPTS = {
    color = { 0.65, 0.65, 0.65, 1.0 },
}
local NPC_CONTROLLER_OPTS = {
    labelWidth = 160,
    controlWidth = 120,
    rangeColumnX = 310,
}

local regionNpcGroups = {}

local function buildRegionBiomeKeyLookup(region)
    local keys = {}
    for _, biome in ipairs(catalog.biomes.ordered or {}) do
        if biome.region == region then
            keys[biome.key] = true
        end
    end
    return keys
end

local function buildRegionNpcGroups(region)
    local groups = {}
    local regionBiomeKeys = buildRegionBiomeKeyLookup(region)
    for _, groupId in ipairs(catalog.npcs.orderedIds or {}) do
        local group = catalog.npcs[groupId]
        local regionDefinitions = {}
        for _, def in ipairs(group and group.definitions or {}) do
            if def.region == region or regionBiomeKeys[def.biome] then
                regionDefinitions[#regionDefinitions + 1] = def
            end
        end
        if #regionDefinitions > 0 then
            groups[#groups + 1] = {
                label = group.label,
                actualNPCName = group.actualNPCName,
                definitions = regionDefinitions,
            }
        end
    end
    return groups
end

local function drawNpcBiomeRow(draw, state, def)
    local imgui = draw.imgui
    imgui.Indent(16)
    components.DrawFixedLabel(draw, def.region, 36)
    imgui.SetCursorPosX(160)
    components.DrawController(draw, state, def.controller, NPC_CONTROLLER_OPTS)
    imgui.Unindent(16)
end

local function drawNpcGroup(draw, state, group)
    draw.widgets.text(group.label, NPC_GROUP_TEXT_OPTS[group.actualNPCName] or DEFAULT_NPC_GROUP_TEXT_OPTS)
    for _, def in ipairs(group.definitions or {}) do
        drawNpcBiomeRow(draw, state, def)
    end
end

local function drawNpcRules(draw, state)
    local imgui = draw.imgui
    imgui.Spacing()
    components.DrawSectionHeading(draw, "NPC Rules", NPC_RULES_HEADING_COLOR)
    draw.widgets.checkbox(state.get("OnlyAllowForcedEncounters"), ONLY_ALLOW_FORCED_ENCOUNTERS_OPTS)
    draw.widgets.text("Blocks NPC encounters left on Default. Only Forced entries can appear.", NPC_RULE_HELP_TEXT_OPTS)
    draw.widgets.checkbox(state.get("IgnoreMaxDepth"), IGNORE_MAX_DEPTH_OPTS)
    draw.widgets.text("Forced NPC encounters can still appear after max depth.", NPC_RULE_HELP_TEXT_OPTS)
    draw.widgets.dropdown(state.get("NPCSpacing"), NPC_SPACING_OPTS)
end

function module.drawRegion(draw, state, region)
    local imgui = draw.imgui
    components.DrawSectionHeading(draw, "NPCs", NPC_HEADING_COLOR)
    local drewAny = false
    for _, group in ipairs(regionNpcGroups[region] or {}) do
        if drewAny then
            imgui.Separator()
        end
        drawNpcGroup(draw, state, group)
        drewAny = true
    end
    drawNpcRules(draw, state)
end

regionNpcGroups.Underworld = buildRegionNpcGroups("Underworld")
regionNpcGroups.Surface = buildRegionNpcGroups("Surface")

return module
