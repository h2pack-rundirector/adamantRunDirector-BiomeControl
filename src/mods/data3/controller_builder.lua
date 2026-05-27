local deps = ...
local definitions = deps.definitions

local controllers = {}

local function makeModeBinding(alias, opts)
    opts = opts or {}
    return {
        alias = alias,
        values = opts.values or definitions.roomModeValues,
        displayValues = opts.displayValues or definitions.roomModeDisplayValues,
        default = opts.default or "default",
    }
end

local function makeRangeBinding(aliasBase, opts)
    opts = opts or {}
    return {
        minAlias = opts.minAlias or (aliasBase .. "Min"),
        maxAlias = opts.maxAlias or (aliasBase .. "Max"),
        min = opts.min,
        max = opts.max,
    }
end

function controllers.modeRange(key, opts)
    opts = opts or {}
    return {
        key = key,
        primitive = opts.primitive or "modeRange",
        label = opts.label,
        helpText = opts.helpText,
        bindings = {
            mode = makeModeBinding(opts.modeAlias or ("Mode" .. key), opts),
            range = makeRangeBinding(opts.rangeAlias or ("Packed" .. key), opts),
        },
    }
end

function controllers.mode(key, opts)
    opts = opts or {}
    return {
        key = key,
        primitive = opts.primitive or "mode",
        label = opts.label,
        roomGroup = opts.roomGroup,
        helpText = opts.helpText,
        bindings = {
            mode = makeModeBinding(opts.modeAlias or key, opts),
        },
    }
end

function controllers.range(key, opts)
    opts = opts or {}
    return {
        key = key,
        primitive = opts.primitive or "range",
        label = opts.label,
        helpText = opts.helpText,
        bindings = {
            range = makeRangeBinding(opts.rangeAlias or key, opts),
        },
    }
end

function controllers.dropdown(key, opts)
    opts = opts or {}
    return {
        key = key,
        primitive = opts.primitive or "dropdown",
        label = opts.label,
        helpText = opts.helpText,
        bindings = {
            value = {
                alias = opts.alias or key,
                type = "string",
                values = opts.values or {},
                displayValues = opts.displayValues or {},
                default = opts.default or "",
                maxLen = opts.maxLen,
            },
        },
    }
end

function controllers.checkbox(key, opts)
    opts = opts or {}
    return {
        key = key,
        primitive = opts.primitive or "checkbox",
        label = opts.label,
        helpText = opts.helpText,
        bindings = {
            value = {
                alias = opts.alias or key,
                type = "bool",
                default = opts.default == true,
            },
        },
    }
end

function controllers.packedCheckboxes(key, opts)
    opts = opts or {}
    return {
        key = key,
        primitive = opts.primitive or "packedCheckboxes",
        label = opts.label,
        helpText = opts.helpText,
        bindings = {
            packed = {
                alias = opts.alias or key,
                options = opts.options or {},
                default = opts.default or 0,
            },
        },
    }
end

return controllers
