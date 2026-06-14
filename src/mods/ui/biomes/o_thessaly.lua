local deps = ...
local module = {}
local biomeStyle = deps.biomeStyle
local uiShared = deps.uiShared
local resolver = deps.resolver

local function drawRoom(ui, entry)
    local opts = biomeStyle.roomControllerOpts(entry.label)
    ui.draw.control(ui.controls.get(entry.controlName), "default", opts)
end

local function drawThessalyMinibossRow(ui)
    ui.draw.control(ui.controls.get(resolver.control("O", "ThessalyMiniBossMode")), "default", biomeStyle.opts.roomController)
end

function module.draw(ui)
    local draw = ui.draw
    local imgui = draw.imgui

    uiShared.DrawSectionHeading(draw, "Rooms", biomeStyle.colors.room)
    drawRoom(ui, resolver.roomInfo("O", "Circe"))
    drawRoom(ui, resolver.roomInfo("O", "Trial"))
    drawRoom(ui, resolver.roomInfo("O", "Fountain"))
    drawRoom(ui, resolver.roomInfo("O", "Shop"))

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    drawThessalyMinibossRow(ui)
    return true
end

return module
