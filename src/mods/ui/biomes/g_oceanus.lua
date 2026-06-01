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
    drawRoom(ui, resolver.room("G", "Narcissus"))
    drawRoom(ui, resolver.room("G", "Trial"))
    drawRoom(ui, resolver.room("G", "Fountain"))
    drawRoom(ui, resolver.room("G", "Shop"))

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    drawRoom(ui, resolver.miniboss("G", "WaterUnit"))
    drawRoom(ui, resolver.miniboss("G", "Crawler"))
    drawRoom(ui, resolver.miniboss("G", "Jellyfish"))
    imgui.Spacing()
    return true
end

return module
