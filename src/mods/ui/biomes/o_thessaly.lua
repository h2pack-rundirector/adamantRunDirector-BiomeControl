local module = {}
local definitions
local catalog
local components

local THESSALY_ROOMS_COLOR = { 0.70, 0.64, 0.95, 1.0 }
local thessalyRoomsSection

local function getThessalyRangeField()
    for _, field in ipairs(catalog.rangeFields or {}) do
        if field.rangeMinAlias == "PackedForcedThessalyMiniBossMin" then
            return field
        end
    end
end

local function drawThessalyMinibossRow(draw, state)
    local imgui = draw.imgui
    local rangeColumnGap = 20
    components.DrawModeRow(draw, state, catalog, "ThessalyMiniBossMode", nil, 200)

    local mode = catalog.GetModeValue(function(key)
        return state.get(key):read()
    end, "ThessalyMiniBossMode")
    local rangeField = getThessalyRangeField()
    if rangeField and (mode == "charybdis" or mode == "captain") then
        imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetCursorPosX() + rangeColumnGap)
        components.DrawRangeDropdowns(
            draw,
            state,
            rangeField.rangeMinAlias,
            rangeField.rangeMaxAlias,
            rangeField.min,
            rangeField.max
        )
    end
end

function module.draw(draw, state)
    components.DrawRoomSection(draw, state, definitions, catalog, "O", thessalyRoomsSection)

    components.DrawSectionHeading(draw, components.SECTION_MINIBOSSES.label, components.SECTION_MINIBOSSES.color)
    drawThessalyMinibossRow(draw, state)
    return true
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    thessalyRoomsSection = {
        label = components.SECTION_ROOMS.label,
        color = THESSALY_ROOMS_COLOR,
        types = components.SECTION_ROOMS.types,
    }
    return module
end

return module
