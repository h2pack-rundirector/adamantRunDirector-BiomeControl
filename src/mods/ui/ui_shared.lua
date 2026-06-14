local uiShared = {}

local MUTED_TEXT_OPTS = {
    color = { 0.65, 0.65, 0.65, 1.0 },
}

local textColorOptsByColor = setmetatable({}, { __mode = "k" })

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

function uiShared.DrawSectionHeading(draw, text, color)
    draw.widgets.text(text, getTextColorOpts(color))
    draw.widgets.separator()
end

function uiShared.DrawMutedText(draw, text)
    draw.widgets.text(text, MUTED_TEXT_OPTS)
end

function uiShared.BuildLabeledOpts(baseOpts)
    local cache = {}
    return function(label)
        local key = tostring(label or "")
        local opts = cache[key]
        if not opts then
            opts = {}
            for optKey, optValue in pairs(baseOpts or {}) do
                opts[optKey] = optValue
            end
            opts.label = label or ""
            cache[key] = opts
        end
        return opts
    end
end

return uiShared
