local deps = ...
local definitions = deps.definitions

local settings = {}

local DEFAULT_ROOM_MODE_VALUES = definitions.roomModeValues
local DEFAULT_ROOM_MODE_DISPLAY_VALUES = definitions.roomModeDisplayValues

local function buildModeRange(name, opts)
    opts = opts or {}
    return {
        name = name,
        template = "ModeWithRange",
        label = opts.label,
        helpText = opts.helpText,
        values = opts.values or DEFAULT_ROOM_MODE_VALUES,
        displayValues = opts.displayValues or DEFAULT_ROOM_MODE_DISPLAY_VALUES,
        default = opts.default or "default",
        range = {
            min = opts.min,
            max = opts.max,
            defaultMin = opts.defaultMin,
            defaultMax = opts.defaultMax,
            visibleWhen = opts.visibleWhen or opts.rangeVisibleWhen,
            controlWidth = opts.controlWidth,
            rangeColumnX = opts.rangeColumnX,
        },
    }
end

function settings.modeWithRange(name, opts)
    return buildModeRange(name, opts)
end

function settings.mode(name, opts)
    opts = opts or {}
    return {
        name = name,
        template = "Mode",
        label = opts.label,
        helpText = opts.helpText,
        values = opts.values or DEFAULT_ROOM_MODE_VALUES,
        displayValues = opts.displayValues or DEFAULT_ROOM_MODE_DISPLAY_VALUES,
        default = opts.default or "default",
    }
end

function settings.choice(name, opts)
    opts = opts or {}
    return {
        name = name,
        template = "Choice",
        label = opts.label,
        helpText = opts.helpText,
        type = opts.type or opts.storageType,
        values = opts.values,
        displayValues = opts.displayValues,
        valueColors = opts.valueColors,
        default = opts.default,
        min = opts.min,
        max = opts.max,
        maxLen = opts.maxLen,
    }
end

function settings.flag(name, opts)
    opts = opts or {}
    return {
        name = name,
        template = "Flag",
        label = opts.label,
        helpText = opts.helpText,
        default = opts.default,
    }
end

function settings.packedSet(name, opts)
    opts = opts or {}
    return {
        name = name,
        template = "PackedSet",
        label = opts.label,
        helpText = opts.helpText,
        options = opts.options,
        default = opts.default,
    }
end

return settings
