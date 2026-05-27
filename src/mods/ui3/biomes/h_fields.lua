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

local function drawRoom(draw, state, def)
    local imgui = draw.imgui
    components.DrawFixedLabel(draw, def.label, 36)
    imgui.SetCursorPosX(160)
    components.DrawController(draw, state, def.controller, ROOM_CONTROLLER_OPTS)
end

function module.draw(draw, state)
    local biome = catalog.biomes.H
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    drawRoom(draw, state, biome.minibosses.Vampire)
    drawRoom(draw, state, biome.minibosses.Lamia)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Special", SPECIAL_COLOR)
    components.DrawController(draw, state, biome.controls.PreventEchoScam.controller)
    imgui.Spacing()
    components.DrawController(draw, state, biome.controls.ForceTwoRewardFieldsOpeners.controller)
    return true
end

return module
