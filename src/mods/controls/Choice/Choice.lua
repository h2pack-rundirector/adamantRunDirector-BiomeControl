local deps = ...

local shared = deps.shared

local Choice = {}

function Choice.prepare(instance)
    instance.values = shared.cloneList(instance.values)
    instance.displayValues = shared.cloneMap(instance.displayValues)
    instance.valueColors = shared.cloneMap(instance.valueColors)
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

return Choice
