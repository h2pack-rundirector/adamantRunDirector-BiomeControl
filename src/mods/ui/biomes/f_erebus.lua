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

    uiShared.DrawSectionHeading(draw, "Rooms", biomeStyle.colors.room)
    drawRoom(ui, resolver.roomInfo("F", "Arachne"))
    drawRoom(ui, resolver.roomInfo("F", "Trial"))
    drawRoom(ui, resolver.roomInfo("F", "Fountain"))
    drawRoom(ui, resolver.roomInfo("F", "Shop"))

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    drawRoom(ui, resolver.minibossInfo("F", "Treant"))
    drawRoom(ui, resolver.minibossInfo("F", "FogEmitter"))
    drawRoom(ui, resolver.minibossInfo("F", "Assassin"))
    imgui.Spacing()
    return true
end

return module
