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

return uiShared
