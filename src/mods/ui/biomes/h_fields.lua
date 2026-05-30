local deps = ...
local module = {}
local catalog = deps.catalog
local components = deps.components

local MINIBOSS_COLOR = { 0.88, 0.38, 0.32, 1.0 }
local SPECIAL_COLOR = { 1.0, 0.60, 0.28, 1.0 }
local ROOM_CONTROLLER_OPTS = {
    label = "",
    controlWidth = 120,
    rangeColumnX = 310,
}

local function drawRoom(ui, def)
    components.DrawSetting(ui, def.setting, ROOM_CONTROLLER_OPTS)
end

function module.draw(ui)
    local draw = ui.draw
    local biome = catalog.biomes.H
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    drawRoom(ui, biome.minibosses.Vampire)
    drawRoom(ui, biome.minibosses.Lamia)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Special", SPECIAL_COLOR)
    components.DrawSetting(ui, biome.controls.PreventEchoScam.setting)
    imgui.Spacing()
    components.DrawSetting(ui, biome.controls.ForceTwoRewardFieldsOpeners.setting)
    return true
end

return module
