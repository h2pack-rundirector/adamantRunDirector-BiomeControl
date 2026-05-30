local components = {}

components.SECTION_ROOMS = {
    label = "Rooms",
    color = { 0.90, 0.82, 0.56, 1.0 },
    types = { "Story", "Trial", "Fountain", "Shop" },
}

components.SECTION_ROOMS_NO_TRIAL = {
    label = "Rooms",
    color = components.SECTION_ROOMS.color,
    types = { "Story", "Fountain", "Shop" },
}

components.SECTION_MINIBOSSES = {
    label = "Minibosses",
    color = { 0.88, 0.38, 0.32, 1.0 },
    types = { "MiniBoss" },
}

local ALIGN_TO_FRAME_PADDING_OPTS = {
    alignToFramePadding = true,
}

local MUTED_TEXT_OPTS = {
    color = { 0.65, 0.65, 0.65, 1.0 },
}

local textColorOptsByColor = setmetatable({}, { __mode = "k" })
local rangeDropdownOptsByMin = {}
local modeDropdownOptsByAlias = {}
local roomModeDropdownOptsByDef = setmetatable({}, { __mode = "k" })
local checkboxOptsByAlias = {}

local function GetTextColorOpts(color)
    if type(color) ~= "table" then
        return nil
    end

    local opts = textColorOptsByColor[color]
    if not opts then
        opts = { color = color }
        textColorOptsByColor[color] = opts
    end
    return opts
end

function components.DrawSectionHeading(draw, text, color)
    draw.widgets.text(text, GetTextColorOpts(color))
    draw.widgets.separator()
end

function components.DrawFixedLabel(draw, label, width)
    local imgui = draw.imgui
    imgui.AlignTextToFramePadding()
    imgui.Text(label)
    imgui.SameLine()
    imgui.SetCursorPosX(width)
end

function components.BuildIntegerValues(minValue, maxValue)
    local values = {}
    for value = minValue, maxValue do
        values[#values + 1] = value
    end
    return values
end

local function GetRangeDropdownOpts(minValue, maxValue)
    local byMax = rangeDropdownOptsByMin[minValue]
    if not byMax then
        byMax = {}
        rangeDropdownOptsByMin[minValue] = byMax
    end

    local opts = byMax[maxValue]
    if not opts then
        opts = {
            label = "",
            values = components.BuildIntegerValues(minValue, maxValue),
            controlWidth = 60,
        }
        byMax[maxValue] = opts
    end
    return opts
end

function components.DrawRangeDropdowns(draw, state, minAlias, maxAlias, minValue, maxValue)
    local imgui = draw.imgui
    local minField = state.get(minAlias)
    local maxField = state.get(maxAlias)
    local opts = GetRangeDropdownOpts(minValue, maxValue)

    draw.widgets.text("from:", ALIGN_TO_FRAME_PADDING_OPTS)
    imgui.SameLine()
    local minChanged = draw.widgets.dropdown(minField, opts)

    imgui.SameLine()
    draw.widgets.text("to", ALIGN_TO_FRAME_PADDING_OPTS)
    imgui.SameLine()
    local maxChanged = draw.widgets.dropdown(maxField, opts)

    local currentMin = tonumber(minField:read()) or minValue
    local currentMax = tonumber(maxField:read()) or maxValue
    if currentMin > currentMax then
        if minChanged and not maxChanged then
            maxField:write(currentMin)
        else
            minField:write(currentMax)
        end
    end
end

local function buildEncodedModeOptions(definitions, def)
    local values = {}
    local displayValues = {}

    for index, value in ipairs(def.modeValues or definitions.roomModeValues) do
        local encoded = index - 1
        values[#values + 1] = encoded
        displayValues[encoded] = (def.modeDisplayValues or definitions.roomModeDisplayValues)[value] or tostring(value)
    end

    return values, displayValues
end

local function GetModeRowDropdownOpts(catalog, alias, label, controlWidth)
    local opts = modeDropdownOptsByAlias[alias]
    if opts then
        return opts
    end

    local entry = catalog.modeEntryLookup[alias]
    local modeValues = {}
    local modeDisplayValues = {}
    for index, value in ipairs(entry and entry.modeValues or {}) do
        local encoded = index - 1
        modeValues[#modeValues + 1] = encoded
        modeDisplayValues[encoded] = entry.modeDisplayValues[value] or tostring(value)
    end

    opts = {
        label = label or (entry and entry.label) or alias,
        tooltip = entry and entry.helpText or nil,
        values = modeValues,
        displayValues = modeDisplayValues,
        labelWidth = 160,
        controlWidth = controlWidth,
    }
    modeDropdownOptsByAlias[alias] = opts
    return opts
end

function components.DrawModeRow(draw, state, catalog, alias, label, controlWidth)
    draw.widgets.dropdown(state.get(alias), GetModeRowDropdownOpts(catalog, alias, label, controlWidth))
end

function components.DrawCheckboxControl(draw, state, control)
    local opts = checkboxOptsByAlias[control.alias]
    if not opts then
        opts = {
            label = control.label,
            tooltip = control.helpText,
        }
        checkboxOptsByAlias[control.alias] = opts
    end
    draw.widgets.checkbox(state.get(control.alias), opts)
end

local function GetRoomModeDropdownOpts(definitions, def)
    local opts = roomModeDropdownOptsByDef[def]
    if opts then
        return opts
    end

    local modeValues, modeDisplayValues = buildEncodedModeOptions(definitions, def)
    opts = {
        label = "",
        values = modeValues,
        displayValues = modeDisplayValues,
        controlWidth = 120,
    }
    roomModeDropdownOptsByDef[def] = opts
    return opts
end

function components.DrawRoomRow(draw, state, definitions, catalog, def)
    local imgui = draw.imgui
    if not def then
        draw.widgets.text("Missing room definition", MUTED_TEXT_OPTS)
        return
    end

    local labelColumnX = 36
    local dropdownColumnX = 160
    local rangeColumnX = 310

    components.DrawFixedLabel(draw, def.label, labelColumnX)
    imgui.SetCursorPosX(dropdownColumnX)
    draw.widgets.dropdown(state.get(def.modeKey), GetRoomModeDropdownOpts(definitions, def))

    if catalog.GetModeValue(function(key)
        return state.get(key):read()
    end, def) == "forced" then
        imgui.SameLine()
        imgui.SetCursorPosX(rangeColumnX)
        components.DrawRangeDropdowns(draw, state, def.rangeMinAlias, def.rangeMaxAlias, def.minDefault, def.maxDefault)
    end
end

function components.DrawRoomSection(draw, state, definitions, catalog, biomeKey, section)
    local imgui = draw.imgui
    local drewSection = false
    local biomeDefinitions = catalog.biomeDefinitions and catalog.biomeDefinitions[biomeKey] or {}

    for _, roomType in ipairs(section.types or {}) do
        for _, def in ipairs(biomeDefinitions[roomType] or {}) do
            if not drewSection then
                components.DrawSectionHeading(draw, section.label, section.color)
                drewSection = true
            end
            components.DrawRoomRow(draw, state, definitions, catalog, def)
        end
    end

    if drewSection then
        imgui.Spacing()
    end
    return drewSection
end

function components.DrawPlaceholder(draw, region)
    draw.widgets.text(region)
    draw.widgets.separator()
    draw.widgets.text("No controls are available for this tab.", MUTED_TEXT_OPTS)
end

return components
