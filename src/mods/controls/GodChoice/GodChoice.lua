local deps = ...

local shared = deps.shared

local GodChoice = {}

local function isValueAvailable(instance, availableGods, value)
    if value == nil or value == "" then
        return true
    end

    local godKey = instance.godKeyByValue and instance.godKeyByValue[value] or nil
    if godKey == nil then
        return true
    end

    if availableGods == nil then
        return true
    end
    return availableGods[godKey] ~= false
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

    function control.readAvailable(_, availableGods)
        local value = fields.Value:read() or instance.default or ""
        if isValueAvailable(instance, availableGods, value) then
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

    function control.refreshVisibility(_, availableGods)
        for _, value in ipairs(instance.values or {}) do
            instance.visibleValues[value] = isValueAvailable(instance, availableGods, value)
        end
    end

    return control
end

function GodChoice.draw(draw, control, instance, opts)
    local target = shared.drawOpts(instance)
    shared.applyCommonDrawOpts(target, opts, instance)
    target.values = instance.values
    target.displayValues = instance.displayValues
    target.valueColors = instance.valueColors
    target.visibleValues = instance.visibleValues
    draw.widgets.dropdown(control:field(), target)
end

return GodChoice
