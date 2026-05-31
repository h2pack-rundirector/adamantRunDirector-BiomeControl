local deps = ...

local shared = deps.shared

local PackedSet = {}

function PackedSet.prepare(instance)
    instance.options = shared.cloneList(instance.options)
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
    instance.width = 0
    for _, bit in ipairs(bits) do
        local used = bit.offset + bit.width
        if used > instance.width then
            instance.width = used
        end
    end
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
            width = instance.width,
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

return PackedSet
