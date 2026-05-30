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

local function drawRoom(ui, def)
    components.DrawSetting(ui, def.setting, ROOM_CONTROLLER_OPTS)
end

function module.draw(ui)
    local draw = ui.draw
    local biome = catalog.biomes.G
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Rooms", ROOM_COLOR)
    drawRoom(ui, biome.rooms.Narcissus)
    drawRoom(ui, biome.rooms.Trial)
    drawRoom(ui, biome.rooms.Fountain)
    drawRoom(ui, biome.rooms.Shop)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    drawRoom(ui, biome.minibosses.WaterUnit)
    drawRoom(ui, biome.minibosses.Crawler)
    drawRoom(ui, biome.minibosses.Jellyfish)
    imgui.Spacing()
    return true
end

return module
