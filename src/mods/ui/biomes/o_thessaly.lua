local deps = ...
local module = {}
local biomeStyle = deps.biomeStyle
local uiShared = deps.uiShared
local resolver = deps.resolver

local function drawRoom(ui, controlName)
    ui.draw.control(ui.controls.get(controlName), "default", biomeStyle.opts.roomController)
end

local function drawThessalyMinibossRow(ui)
    ui.draw.control(ui.controls.get(resolver.control("O", "ThessalyMiniBossMode")), "default", {
        labelWidth = 160,
        controlWidth = 200,
        rangeColumnX = 410,
    })
end

function module.draw(ui)
    local draw = ui.draw
    local imgui = draw.imgui

    uiShared.DrawSectionHeading(draw, "Rooms", biomeStyle.colors.room)
    drawRoom(ui, resolver.room("O", "Circe"))
    drawRoom(ui, resolver.room("O", "Trial"))
    drawRoom(ui, resolver.room("O", "Fountain"))
    drawRoom(ui, resolver.room("O", "Shop"))

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    drawThessalyMinibossRow(ui)
    return true
end

return module
