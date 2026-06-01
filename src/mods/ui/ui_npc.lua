local deps = ...
local module = {}
local uiShared = deps.uiShared
local resolver = deps.resolver

local style = {
    colors = {
        heading = { 0.90, 0.82, 0.56, 1.0 },
        rulesHeading = { 0.70, 0.84, 0.96, 1.0 },
    },
    opts = {
        groupText = {
            Artemis = { color = { 15 / 255, 255 / 255, 9 / 255, 1.0 } },
            Nemesis = { color = { 115 / 255, 146 / 255, 210 / 255, 1.0 } },
            Athena = { color = { 255 / 255, 216 / 255, 60 / 255, 1.0 } },
            Heracles = { color = { 255 / 255, 125 / 255, 25 / 255, 1.0 } },
            Icarus = { color = { 243 / 255, 215 / 255, 116 / 255, 1.0 } },
        },
        npcSpacing = {
            label = "Minimum rooms between field NPC encounters",
            labelWidth = 260,
            controlWidth = 60,
        },
        npcController = {
            labelWidth = 160,
            controlWidth = 120,
            rangeColumnX = 310,
        },
        ruleFlag = {},
    },
}
style.opts.defaultGroupText = {
    color = style.colors.heading,
}

local ONLY_ALLOW_FORCED_CONTROL = "OnlyAllowForcedEncounters"
local IGNORE_MAX_DEPTH_CONTROL = "IgnoreMaxDepth"
local NPC_SPACING_CONTROL = "NPCSpacing"

local function drawNpcBiomeRow(ui, def)
    local draw = ui.draw
    local imgui = draw.imgui
    imgui.Indent(16)
    style.opts.npcController.label = def.biomeLabel
    ui.draw.control(ui.controls.get(def.controlName), "default", style.opts.npcController)
    imgui.Unindent(16)
end

local function drawNpcGroup(ui, group)
    local draw = ui.draw
    draw.widgets.text(group.label, style.opts.groupText[group.actualNPCName] or style.opts.defaultGroupText)
    for _, def in ipairs(group.entries or {}) do
        drawNpcBiomeRow(ui, def)
    end
end

local function drawNpcRules(ui)
    local draw = ui.draw
    local imgui = draw.imgui
    imgui.Spacing()
    uiShared.DrawSectionHeading(draw, "NPC Rules", style.colors.rulesHeading)
    draw.control(ui.controls.get(ONLY_ALLOW_FORCED_CONTROL), "default", style.opts.ruleFlag)
    uiShared.DrawMutedText(draw, "Blocks NPC encounters left on Default. Only Forced entries can appear.")
    draw.control(ui.controls.get(IGNORE_MAX_DEPTH_CONTROL), "default", style.opts.ruleFlag)
    uiShared.DrawMutedText(draw, "Forced NPC encounters can still appear after max depth.")
    draw.control(ui.controls.get(NPC_SPACING_CONTROL), "default", style.opts.npcSpacing)
end

function module.drawRegion(ui, region)
    local draw = ui.draw
    local imgui = draw.imgui
    uiShared.DrawSectionHeading(draw, "NPCs", style.colors.heading)
    local drewAny = false
    for _, group in ipairs(resolver.npcGroups(region)) do
        if drewAny then
            imgui.Separator()
        end
        drawNpcGroup(ui, group)
        drewAny = true
    end
    drawNpcRules(ui)
end

return module
