local deps = ...
local module = {}
local catalog = deps.catalog
local components = deps.components

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
    local biome = catalog.biomes.I
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    drawRoom(ui, biome.minibosses.RatCatcher)
    drawRoom(ui, biome.minibosses.GoldElemental)
    imgui.Spacing()
    return true
end

return module
