local deps = ...

local shared = deps.shared

local base = {}

function base.prepare(instance)
    instance.values = shared.cloneList(instance.values)
    instance.displayValues = shared.cloneMap(instance.displayValues)
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

function base.modeFromField(fields, instance)
    local encoded = math.floor(tonumber(fields.Mode:read()) or 0)
    return instance.values[encoded + 1] or instance.default
end

function base.storage(instance)
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

function base.dropdownOpts(instance, opts)
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

function base.createRuntime(fields, instance)
    local control = {}

    function control.mode()
        return base.modeFromField(fields, instance)
    end

    function control:isMode(value)
        return self:mode() == value
    end

    function control:read()
        return self:mode()
    end

    return control
end

function base.addUiMethods(control, fields, instance)
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

function base.createUi(fields, instance)
    return base.addUiMethods(base.createRuntime(fields, instance), fields, instance)
end

function base.draw(draw, control, instance, opts)
    draw.widgets.dropdown(control:field("Mode"), base.dropdownOpts(instance, opts))
end

return base
