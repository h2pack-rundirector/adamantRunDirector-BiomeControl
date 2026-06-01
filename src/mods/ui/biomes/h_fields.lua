local deps = ...
local module = {}
local biomeStyle = deps.biomeStyle
local uiShared = deps.uiShared
local resolver = deps.resolver

local function drawRoom(ui, controlName)
    ui.draw.control(ui.controls.get(controlName), "default", biomeStyle.opts.roomController)
end

function module.draw(ui)
    local draw = ui.draw
    local imgui = draw.imgui

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    drawRoom(ui, resolver.miniboss("H", "Vampire"))
    drawRoom(ui, resolver.miniboss("H", "Lamia"))

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Special", biomeStyle.colors.special)
    draw.control(ui.controls.get(resolver.control("H", "PreventEchoScam")))
    imgui.Spacing()
    draw.control(ui.controls.get(resolver.control("H", "ForceTwoRewardFieldsOpeners")))
    return true
end

return module
