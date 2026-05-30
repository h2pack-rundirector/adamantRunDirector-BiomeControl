local components = {}

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

function components.DrawSectionHeading(draw, text, color)
    draw.widgets.text(text, getTextColorOpts(color))
    draw.widgets.separator()
end

function components.DrawMutedText(draw, text)
    draw.widgets.text(text, MUTED_TEXT_OPTS)
end

function components.DrawSetting(ui, setting, opts)
    if setting == nil then
        return false
    end
    return ui.draw.control(ui.controls.get(setting.name), "default", opts)
end

function components.DrawPlaceholder(draw, region)
    draw.widgets.text(region)
    draw.widgets.separator()
    components.DrawMutedText(draw, "No controls are available for this tab.")
end

return components
