local components = {}

local ALIGN_TO_FRAME_PADDING_OPTS = {
    alignToFramePadding = true,
}

local MUTED_TEXT_OPTS = {
    color = { 0.65, 0.65, 0.65, 1.0 },
}

local textColorOptsByColor = setmetatable({}, { __mode = "k" })
local rangeDropdownOptsByMin = {}
local modeDropdownOptsByController = setmetatable({}, { __mode = "k" })
local dropdownOptsByController = setmetatable({}, { __mode = "k" })
local checkboxOptsByController = setmetatable({}, { __mode = "k" })
local packedOptsByController = setmetatable({}, { __mode = "k" })
local packedLabelOptsByController = setmetatable({}, { __mode = "k" })

local function getTextColorOpts(color)
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

local function buildIntegerValues(minValue, maxValue)
    local values = {}
    for value = minValue, maxValue do
        values[#values + 1] = value
    end
    return values
end

local function getRangeDropdownOpts(minValue, maxValue)
    local byMax = rangeDropdownOptsByMin[minValue]
    if not byMax then
        byMax = {}
        rangeDropdownOptsByMin[minValue] = byMax
    end

    local opts = byMax[maxValue]
    if not opts then
        opts = {
            label = "",
            values = buildIntegerValues(minValue, maxValue),
            controlWidth = 60,
        }
        byMax[maxValue] = opts
    end
    return opts
end

local function getModeDropdownOpts(controller, opts)
    local cached = modeDropdownOptsByController[controller]
    if cached then
        return cached
    end

    local mode = controller.bindings.mode
    local values = {}
    local displayValues = {}
    for index, value in ipairs(mode.values or {}) do
        local encoded = index - 1
        values[#values + 1] = encoded
        displayValues[encoded] = mode.displayValues[value] or tostring(value)
    end

    cached = {
        label = opts and opts.label or controller.label or "",
        tooltip = controller.helpText,
        values = values,
        displayValues = displayValues,
        labelWidth = opts and opts.labelWidth,
        controlWidth = opts and opts.controlWidth,
    }
    modeDropdownOptsByController[controller] = cached
    return cached
end

local function getDropdownOpts(controller, opts)
    local cached = dropdownOptsByController[controller]
    if cached then
        return cached
    end

    local value = controller.bindings.value
    cached = {
        label = opts and opts.label or controller.label or "",
        tooltip = controller.helpText,
        values = value.values,
        displayValues = value.displayValues,
        labelWidth = opts and opts.labelWidth,
        controlWidth = opts and opts.controlWidth,
    }
    dropdownOptsByController[controller] = cached
    return cached
end

local function getCheckboxOpts(controller, opts)
    local cached = checkboxOptsByController[controller]
    if cached then
        return cached
    end

    cached = {
        label = opts and opts.label or controller.label or "",
        tooltip = controller.helpText,
    }
    checkboxOptsByController[controller] = cached
    return cached
end

local function getPackedOpts(controller)
    local cached = packedOptsByController[controller]
    if cached then
        return cached
    end

    local packed = controller.bindings.packed
    cached = {
        slotCount = #(packed.options or {}),
    }
    packedOptsByController[controller] = cached
    return cached
end

local function getPackedLabelOpts(controller)
    local cached = packedLabelOptsByController[controller]
    if cached then
        return cached
    end

    cached = {
        tooltip = controller.helpText,
    }
    packedLabelOptsByController[controller] = cached
    return cached
end

function components.GetModeValue(state, controller)
    local mode = controller.bindings.mode
    if not mode then
        return "default"
    end

    local encoded = state.get(mode.alias):read()
    encoded = math.floor(tonumber(encoded) or 0)
    return mode.values[encoded + 1] or mode.default
end

function components.DrawSectionHeading(draw, text, color)
    draw.widgets.text(text, getTextColorOpts(color))
    draw.widgets.separator()
end

function components.DrawFixedLabel(draw, label, width)
    local imgui = draw.imgui
    imgui.AlignTextToFramePadding()
    imgui.Text(label)
    imgui.SameLine()
    imgui.SetCursorPosX(width)
end

function components.DrawMutedText(draw, text)
    draw.widgets.text(text, MUTED_TEXT_OPTS)
end

function components.DrawRange(draw, state, controller)
    local range = controller.bindings.range
    local imgui = draw.imgui
    local minField = state.get(range.minAlias)
    local maxField = state.get(range.maxAlias)
    local opts = getRangeDropdownOpts(range.min, range.max)

    draw.widgets.text("from:", ALIGN_TO_FRAME_PADDING_OPTS)
    imgui.SameLine()
    local minChanged = draw.widgets.dropdown(minField, opts)

    imgui.SameLine()
    draw.widgets.text("to", ALIGN_TO_FRAME_PADDING_OPTS)
    imgui.SameLine()
    local maxChanged = draw.widgets.dropdown(maxField, opts)

    local currentMin = tonumber(minField:read()) or range.min
    local currentMax = tonumber(maxField:read()) or range.max
    if currentMin > currentMax then
        if minChanged and not maxChanged then
            maxField:write(currentMin)
        else
            minField:write(currentMax)
        end
    end
end

function components.DrawMode(draw, state, controller, opts)
    local mode = controller.bindings.mode
    draw.widgets.dropdown(state.get(mode.alias), getModeDropdownOpts(controller, opts))
end

function components.DrawDropdown(draw, state, controller, opts)
    local value = controller.bindings.value
    draw.widgets.dropdown(state.get(value.alias), getDropdownOpts(controller, opts))
end

function components.DrawCheckbox(draw, state, controller, opts)
    local value = controller.bindings.value
    draw.widgets.checkbox(state.get(value.alias), getCheckboxOpts(controller, opts))
end

function components.DrawPackedCheckboxes(draw, state, controller)
    local packed = controller.bindings.packed
    draw.widgets.text(controller.label or packed.alias, getPackedLabelOpts(controller))
    draw.widgets.packedCheckboxList(state.get(packed.alias), getPackedOpts(controller))
end

function components.DrawModeRange(draw, state, controller, opts)
    components.DrawMode(draw, state, controller, opts)
    if components.GetModeValue(state, controller) ~= "forced" then
        return
    end

    local imgui = draw.imgui
    imgui.SameLine()
    imgui.SetCursorPosX(opts and opts.rangeColumnX or 310)
    components.DrawRange(draw, state, controller)
end

function components.DrawPlaceholder(draw, region)
    draw.widgets.text(region)
    draw.widgets.separator()
    components.DrawMutedText(draw, "No controls are available for this tab.")
end

return components
