local deps = ...
local module = {}
local biomeStyle = deps.biomeStyle
local uiShared = deps.uiShared
local resolver = deps.resolver

local function drawRoom(ui, entry)
    local opts = biomeStyle.opts.roomController
    opts.label = entry.label
    ui.draw.control(ui.controls.get(entry.controlName), "default", opts)
end

function module.draw(ui)
    local draw = ui.draw
    local imgui = draw.imgui

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    drawRoom(ui, resolver.minibossInfo("I", "RatCatcher"))
    drawRoom(ui, resolver.minibossInfo("I", "GoldElemental"))
    imgui.Spacing()
    return true
end

return module
