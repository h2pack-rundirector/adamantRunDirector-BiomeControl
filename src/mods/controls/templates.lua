local function cloneList(values)
    local copy = {}
    for index, value in ipairs(values or {}) do
        copy[index] = value
    end
    return copy
end

local function cloneMap(values)
    local copy = {}
    for key, value in pairs(values or {}) do
        copy[key] = value
    end
    return copy
end

local function buildIntegerValues(minValue, maxValue)
    local values = {}
    for value = minValue, maxValue do
        values[#values + 1] = value
    end
    return values
end

local function normalizeModeInstance(instance)
    instance.values = cloneList(instance.values)
    instance.displayValues = cloneMap(instance.displayValues)
    instance.default = instance.default or instance.values[1] or "default"
    instance.valueLookup = {}
    instance.encodedValues = {}
    instance.encodedDisplayValues = {}

    for index, value in ipairs(instance.values) do
        local encoded = index - 1
        instance.valueLookup[value] = encoded
        instance.encodedValues[#instance.encodedValues + 1] = encoded
        instance.encodedDisplayValues[encoded] = instance.displayValues[value] or tostring(value)
    end

    return instance
end

local function modeFromField(fields, instance)
    local encoded = math.floor(tonumber(fields.Mode:read()) or 0)
    return instance.values[encoded + 1] or instance.default
end

local function modeStorage(instance)
    return {
        {
            key = "Mode",
            type = "int",
            default = instance.valueLookup[instance.default] or 0,
            min = 0,
            max = math.max(#instance.values - 1, 0),
        },
    }
end

local function modeDropdownOpts(instance, opts)
    local target = opts or instance.modeOpts
    if not target then
        target = {}
        instance.modeOpts = target
    end

    if opts then
        target.label = opts.label or instance.label or ""
    elseif target.label == nil then
        target.label = instance.label or ""
    end
    target.tooltip = instance.helpText
    target.values = instance.encodedValues
    target.displayValues = instance.encodedDisplayValues
    return target
end

local function createModeRuntime(fields, instance)
    local control = {}

    function control.mode()
        return modeFromField(fields, instance)
    end

    function control:isMode(value)
        return self:mode() == value
    end

    function control:read()
        return self:mode()
    end

    return control
end

local function createModeUi(fields, instance)
    local control = createModeRuntime(fields, instance)

    function control.field(_, key)
        return fields[key]
    end

    function control.writeMode(_, value)
        local encoded = instance.valueLookup[value]
        if encoded == nil then
            encoded = instance.valueLookup[instance.default] or 0
        end
        return fields.Mode:write(encoded)
    end

    return control
end

local function drawMode(draw, control, instance, opts)
    draw.widgets.dropdown(control:field("Mode"), modeDropdownOpts(instance, opts))
end

local Flag = {}

function Flag.prepare(instance)
    instance.default = instance.default == true
    return instance
end

function Flag.storage(instance)
    return {
        {
            key = "Value",
            type = "bool",
            default = instance.default,
        },
    }
end

function Flag.createRuntime(fields)
    local control = {}

    function control.read()
        return fields.Value:read() == true
    end

    function control:isEnabled()
        return self:read()
    end

    return control
end

function Flag.createUi(fields)
    local control = Flag.createRuntime(fields)

    function control.field()
        return fields.Value
    end

    function control.write(_, value)
        return fields.Value:write(value == true)
    end

    return control
end

function Flag.draw(draw, control, instance, opts)
    local target = opts or instance.drawOpts
    if not target then
        target = {}
        instance.drawOpts = target
    end
    if opts then
        target.label = opts.label or instance.label or ""
    elseif target.label == nil then
        target.label = instance.label or ""
    end
    target.tooltip = instance.helpText
    draw.widgets.checkbox(control:field(), target)
end

local Choice = {}

function Choice.prepare(instance)
    instance.values = cloneList(instance.values)
    instance.displayValues = cloneMap(instance.displayValues)
    instance.valueColors = cloneMap(instance.valueColors)
    instance.storageType = instance.type or instance.storageType or "string"
    if instance.default == nil then
        instance.default = instance.values[1]
    end
    if instance.default == nil then
        instance.default = instance.storageType == "int" and 0 or ""
    end
    return instance
end

function Choice.storage(instance)
    return {
        {
            key = "Value",
            type = instance.storageType,
            default = instance.default,
            min = instance.min,
            max = instance.max,
            maxLen = instance.maxLen,
        },
    }
end

function Choice.createRuntime(fields)
    local control = {}

    function control.read()
        return fields.Value:read()
    end

    function control:is(value)
        return self:read() == value
    end

    return control
end

function Choice.createUi(fields)
    local control = Choice.createRuntime(fields)

    function control.field()
        return fields.Value
    end

    function control.write(_, value)
        return fields.Value:write(value)
    end

    return control
end

function Choice.draw(draw, control, instance, opts)
    local target = opts or instance.drawOpts
    if not target then
        target = {}
        instance.drawOpts = target
    end
    if opts then
        target.label = opts.label or instance.label or ""
    elseif target.label == nil then
        target.label = instance.label or ""
    end
    target.tooltip = instance.helpText
    target.values = instance.values
    target.displayValues = instance.displayValues
    target.valueColors = instance.valueColors
    draw.widgets.dropdown(control:field(), target)
end

local Mode = {}

function Mode.prepare(instance)
    return normalizeModeInstance(instance)
end

Mode.storage = modeStorage
Mode.createRuntime = createModeRuntime
Mode.createUi = createModeUi
Mode.draw = drawMode

local ModeWithRange = {}

function ModeWithRange.prepare(instance)
    normalizeModeInstance(instance)
    instance.range = instance.range or {}
    instance.range.min = instance.range.min or instance.min or 0
    instance.range.max = instance.range.max or instance.max or instance.range.min
    instance.range.defaultMin = instance.range.defaultMin or instance.range.min
    instance.range.defaultMax = instance.range.defaultMax or instance.range.max
    instance.range.visibleWhen = instance.range.visibleWhen or {
        forced = true,
    }
    instance.range.values = buildIntegerValues(instance.range.min, instance.range.max)
    instance.range.opts = {
        label = "",
        values = instance.range.values,
        controlWidth = instance.range.controlWidth or 60,
    }
    return instance
end

function ModeWithRange.storage(instance)
    return {
        modeStorage(instance)[1],
        {
            key = "Min",
            type = "int",
            default = instance.range.defaultMin,
            min = instance.range.min,
            max = instance.range.max,
        },
        {
            key = "Max",
            type = "int",
            default = instance.range.defaultMax,
            min = instance.range.min,
            max = instance.range.max,
        },
    }
end

local function readRange(fields, instance)
    return fields.Min:read() or instance.range.min, fields.Max:read() or instance.range.max
end

function ModeWithRange.createRuntime(fields, instance)
    local control = createModeRuntime(fields, instance)

    function control.range()
        return readRange(fields, instance)
    end

    function control:read()
        local minValue, maxValue = self:range()
        return {
            mode = self:mode(),
            min = minValue,
            max = maxValue,
        }
    end

    return control
end

function ModeWithRange.createUi(fields, instance)
    local control = ModeWithRange.createRuntime(fields, instance)

    function control.field(_, key)
        return fields[key]
    end

    function control.writeMode(_, value)
        local encoded = instance.valueLookup[value]
        if encoded == nil then
            encoded = instance.valueLookup[instance.default] or 0
        end
        return fields.Mode:write(encoded)
    end

    return control
end

local function drawRange(draw, control, instance)
    local imgui = draw.imgui
    local minField = control:field("Min")
    local maxField = control:field("Max")
    local rangeOpts = instance.range.opts

    draw.widgets.text("from:", {
        alignToFramePadding = true,
    })
    imgui.SameLine()
    local minChanged = draw.widgets.dropdown(minField, rangeOpts)

    imgui.SameLine()
    draw.widgets.text("to", {
        alignToFramePadding = true,
    })
    imgui.SameLine()
    local maxChanged = draw.widgets.dropdown(maxField, rangeOpts)

    local currentMin = tonumber(minField:read()) or instance.range.min
    local currentMax = tonumber(maxField:read()) or instance.range.max
    if currentMin > currentMax then
        if minChanged and not maxChanged then
            maxField:write(currentMin)
        else
            minField:write(currentMax)
        end
    end
end

function ModeWithRange.draw(draw, control, instance, opts)
    drawMode(draw, control, instance, opts)
    if instance.range.visibleWhen[control:mode()] ~= true then
        return
    end

    local imgui = draw.imgui
    imgui.SameLine()
    imgui.SetCursorPosX(opts and opts.rangeColumnX or instance.range.rangeColumnX or 310)
    drawRange(draw, control, instance)
end

local PackedSet = {}

function PackedSet.prepare(instance)
    instance.options = cloneList(instance.options)
    instance.optionByKey = {}
    local bits = {}
    for _, option in ipairs(instance.options) do
        local key = option.key or option.name or ("Bit" .. tostring(option.bit or 0))
        option.key = key
        option.mask = bit32.lshift(1, option.bit or 0)
        instance.optionByKey[key] = option
        bits[#bits + 1] = {
            key = key,
            label = option.label or key,
            type = "bool",
            offset = option.bit or 0,
            width = 1,
            default = option.default == true,
        }
    end
    instance.bits = bits
    instance.default = instance.default or 0
    instance.labelOpts = {
        tooltip = instance.helpText,
    }
    instance.packedOpts = {
        slotCount = #instance.options,
    }
    return instance
end

function PackedSet.storage(instance)
    return {
        {
            key = "Value",
            type = "packedInt",
            default = instance.default,
            bits = instance.bits,
        },
    }
end

function PackedSet.createRuntime(fields, instance)
    local control = {}

    function control.mask()
        return fields.Value:read() or 0
    end

    function control:isSelected(key)
        local option = instance.optionByKey[key]
        return option ~= nil and bit32.band(self:mask(), option.mask) ~= 0
    end

    function control.options()
        return instance.options
    end

    function control:read()
        return self:mask()
    end

    return control
end

function PackedSet.createUi(fields, instance)
    local control = PackedSet.createRuntime(fields, instance)

    function control.field()
        return fields.Value
    end

    return control
end

function PackedSet.draw(draw, control, instance)
    draw.widgets.text(instance.label or instance.name, instance.labelOpts)
    draw.widgets.packedCheckboxList(control:field(), instance.packedOpts)
end

return {
    Flag = Flag,
    Choice = Choice,
    Mode = Mode,
    ModeWithRange = ModeWithRange,
    PackedSet = PackedSet,
}
