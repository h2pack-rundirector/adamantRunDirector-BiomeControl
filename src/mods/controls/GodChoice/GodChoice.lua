local deps = ...

local shared = deps.shared
local godAvailability = deps.godAvailability

local GodChoice = {}

local function isValueAvailable(source, instance, value)
    if value == nil or value == "" then
        return true
    end

    local godKey = instance.godKeyByValue and instance.godKeyByValue[value] or nil
    if godKey == nil then
        return true
    end

    if not godAvailability then
        return true
    end
    return godAvailability.isAvailable(source, godKey)
end

function GodChoice.prepare(instance)
    instance.values = shared.cloneList(instance.values)
    instance.displayValues = shared.cloneMap(instance.displayValues)
    instance.valueColors = shared.cloneMap(instance.valueColors)
    instance.godKeyByValue = shared.cloneMap(instance.godKeyByValue)
    instance.visibleValues = shared.cloneMap(instance.visibleValues)
    if instance.default == nil then
        instance.default = ""
    end
    return instance
end

function GodChoice.storage(instance)
    return {
        {
            key = "Value",
            type = "string",
            default = instance.default,
            maxLen = instance.maxLen or 64,
        },
    }
end

function GodChoice.createRuntime(fields, instance)
    local control = {}

    function control.read()
        return fields.Value:read() or instance.default or ""
    end

    function control.readAvailable(_, source)
        local value = fields.Value:read() or instance.default or ""
        if isValueAvailable(source, instance, value) then
            return value
        end
        return instance.default or ""
    end

    return control
end

function GodChoice.createUi(fields, instance)
    local control = GodChoice.createRuntime(fields, instance)

    function control.field()
        return fields.Value
    end

    function control.write(_, value)
        return fields.Value:write(value)
    end

    function control.refreshVisibility(_, source)
        for _, value in ipairs(instance.values or {}) do
            instance.visibleValues[value] = isValueAvailable(source, instance, value)
        end
    end

    return control
end

function GodChoice.draw(draw, control, instance, opts)
    local target = instance.drawOpts
    if not target then
        target = {}
        instance.drawOpts = target
    end
    target.label = opts and opts.label or instance.label or ""
    target.tooltip = instance.helpText
    target.labelWidth = opts and opts.labelWidth or nil
    target.controlWidth = opts and opts.controlWidth or nil
    target.controlGap = opts and opts.controlGap or nil
    target.action = opts and opts.action or nil
    target.value = opts and opts.value or nil
    target.values = instance.values
    target.displayValues = instance.displayValues
    target.valueColors = instance.valueColors
    target.visibleValues = instance.visibleValues
    draw.widgets.dropdown(control:field(), target)
end

return GodChoice
