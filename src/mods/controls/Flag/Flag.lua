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

return Flag
