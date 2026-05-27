local deps = ...
local module = {}
local catalog = deps.catalog
local components = deps.components

local ROOM_COLOR = { 0.90, 0.82, 0.56, 1.0 }
local MINIBOSS_COLOR = { 0.88, 0.38, 0.32, 1.0 }
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
    local biome = catalog.biomes.P
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Rooms", ROOM_COLOR)
    drawRoom(draw, state, biome.rooms.Dionysus)
    drawRoom(draw, state, biome.rooms.Fountain)
    drawRoom(draw, state, biome.rooms.Shop)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    drawRoom(draw, state, biome.minibosses.Talos)
    drawRoom(draw, state, biome.minibosses.Dragon)
    imgui.Spacing()
    return true
end

return module
