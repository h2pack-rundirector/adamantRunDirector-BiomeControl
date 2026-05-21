local module = {}
local definitions
local catalog
local components

local ROOM_SECTION = {
    label = "Rooms",
    types = { "Story", "Trial", "Fountain", "Shop" },
    color = { 0.70, 0.64, 0.95, 1.0 },
}

local function getThessalyRangeField()
    for _, field in ipairs(catalog.rangeFields or {}) do
        if field.rangeMinAlias == "PackedForcedThessalyMiniBossMin" then
            return field
        end
    end
end

local function drawThessalyMinibossRow(draw, data)
    local imgui = draw.imgui
    local rangeColumnGap = 20
    components.DrawModeRow(draw, data, catalog, "ThessalyMiniBossMode", nil, 200)

    local mode = catalog.GetModeValue(function(key)
        return data.get(key):read()
    end, "ThessalyMiniBossMode")
    local rangeField = getThessalyRangeField()
    if rangeField and (mode == "charybdis" or mode == "captain") then
        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetCursorPosX() + rangeColumnGap)
        components.DrawRangeDropdowns(
            draw,
            data,
            rangeField.rangeMinAlias,
            rangeField.rangeMaxAlias,
            rangeField.min,
            rangeField.max
        )
    end
end

function module.draw(draw, data)
    components.DrawRoomSection(draw, data, definitions, catalog, "O", ROOM_SECTION)

    components.DrawSectionHeading(draw, "Minibosses", { 0.88, 0.38, 0.32, 1.0 })
    drawThessalyMinibossRow(draw, data)
    return true
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
