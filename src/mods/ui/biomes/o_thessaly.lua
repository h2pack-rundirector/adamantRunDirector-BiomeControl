local deps = ...
local module = {}
local catalog = deps.catalog
local components = deps.components

local THESSALY_ROOMS_COLOR = { 0.70, 0.64, 0.95, 1.0 }
local MINIBOSS_COLOR = { 0.88, 0.38, 0.32, 1.0 }
local ROOM_CONTROLLER_OPTS = {
    label = "",
    controlWidth = 120,
    rangeColumnX = 310,
}

local function drawRoom(ui, def)
    components.DrawSetting(ui, def.setting, ROOM_CONTROLLER_OPTS)
end

local function drawThessalyMinibossRow(ui)
    local entry = catalog.biomes.O.controls.ThessalyMiniBossMode
    components.DrawSetting(ui, entry and entry.setting, {
        labelWidth = 160,
        controlWidth = 200,
        rangeColumnX = 410,
    })
end

function module.draw(ui)
    local draw = ui.draw
    local biome = catalog.biomes.O
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Rooms", THESSALY_ROOMS_COLOR)
    drawRoom(ui, biome.rooms.Circe)
    drawRoom(ui, biome.rooms.Trial)
    drawRoom(ui, biome.rooms.Fountain)
    drawRoom(ui, biome.rooms.Shop)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    drawThessalyMinibossRow(ui)
    return true
end

return module
