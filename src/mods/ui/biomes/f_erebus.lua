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

    uiShared.DrawSectionHeading(draw, "Rooms", biomeStyle.colors.room)
    drawRoom(ui, resolver.room("F", "Arachne"))
    drawRoom(ui, resolver.room("F", "Trial"))
    drawRoom(ui, resolver.room("F", "Fountain"))
    drawRoom(ui, resolver.room("F", "Shop"))

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    drawRoom(ui, resolver.miniboss("F", "Treant"))
    drawRoom(ui, resolver.miniboss("F", "FogEmitter"))
    drawRoom(ui, resolver.miniboss("F", "Assassin"))
    imgui.Spacing()
    return true
end

return module
