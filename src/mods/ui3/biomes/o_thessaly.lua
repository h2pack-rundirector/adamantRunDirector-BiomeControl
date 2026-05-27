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

local function drawRoom(draw, state, def)
    local imgui = draw.imgui
    components.DrawFixedLabel(draw, def.label, 36)
    imgui.SetCursorPosX(160)
    components.DrawController(draw, state, def.controller, ROOM_CONTROLLER_OPTS)
end

local function getThessalyController(key)
    local entry = catalog.biomes.O.controls[key]
    return entry and entry.controller
end

local function drawThessalyMinibossRow(draw, state)
    local imgui = draw.imgui
    local modeController = getThessalyController("ThessalyMiniBossMode")
    local rangeController = getThessalyController("ForcedThessalyMiniBoss")

    components.DrawController(draw, state, modeController, {
        label = modeController and modeController.label,
        labelWidth = 160,
        controlWidth = 200,
    })

    local value = modeController and components.GetModeValue(state, modeController)
    if rangeController and (value == "charybdis" or value == "captain") then
        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetCursorPosX() + 20)
        components.DrawController(draw, state, rangeController)
    end
end

function module.draw(draw, state)
    local biome = catalog.biomes.O
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Rooms", THESSALY_ROOMS_COLOR)
    drawRoom(draw, state, biome.rooms.Circe)
    drawRoom(draw, state, biome.rooms.Trial)
    drawRoom(draw, state, biome.rooms.Fountain)
    drawRoom(draw, state, biome.rooms.Shop)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    drawThessalyMinibossRow(draw, state)
    return true
end

return module
