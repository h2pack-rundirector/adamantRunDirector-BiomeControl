local components = {}

function components.DrawSectionHeading(draw, text, color)
    draw.widgets.text(text, { color = color })
    draw.widgets.separator()
end

function components.DrawFixedLabel(draw, label, width)
    local imgui = draw.imgui
    imgui.AlignTextToFramePadding()
    imgui.Text(label)
    imgui.SameLine()
    imgui.SetCursorPosX(width)
end

function components.BuildIntegerValues(minValue, maxValue)
    local values = {}
    for value = minValue, maxValue do
        values[#values + 1] = value
    end
    return values
end

function components.DrawRangeDropdowns(draw, data, minAlias, maxAlias, minValue, maxValue)
    local imgui = draw.imgui
    local minField = data.get(minAlias)
    local maxField = data.get(maxAlias)
    local values = components.BuildIntegerValues(minValue, maxValue)

    draw.widgets.text("from:", { alignToFramePadding = true })
    imgui.SameLine()
    local minChanged = draw.widgets.dropdown(minField, {
        label = "",
        values = values,
        controlWidth = 60,
    })

    imgui.SameLine()
    draw.widgets.text("to", { alignToFramePadding = true })
    imgui.SameLine()
    local maxChanged = draw.widgets.dropdown(maxField, {
        label = "",
        values = values,
        controlWidth = 60,
    })

    local currentMin = tonumber(minField:read()) or minValue
    local currentMax = tonumber(maxField:read()) or maxValue
    if currentMin > currentMax then
        if minChanged and not maxChanged then
            maxField:write(currentMin)
        else
            minField:write(currentMax)
        end
    end
end

local function buildEncodedModeOptions(definitions, def)
    local values = {}
    local displayValues = {}

    for index, value in ipairs(def.modeValues or definitions.roomModeValues) do
        local encoded = index - 1
        values[#values + 1] = encoded
        displayValues[encoded] = (def.modeDisplayValues or definitions.roomModeDisplayValues)[value] or tostring(value)
    end

    return values, displayValues
end

function components.DrawModeRow(draw, data, catalog, alias, label, controlWidth)
    local entry = catalog.modeEntryLookup[alias]
    local modeValues = {}
    local modeDisplayValues = {}

    for index, value in ipairs(entry and entry.modeValues or {}) do
        local encoded = index - 1
        modeValues[#modeValues + 1] = encoded
        modeDisplayValues[encoded] = entry.modeDisplayValues[value] or tostring(value)
    end

    draw.widgets.dropdown(data.get(alias), {
        label = label or (entry and entry.label) or alias,
        tooltip = entry and entry.helpText or nil,
        values = modeValues,
        displayValues = modeDisplayValues,
        labelWidth = 160,
        controlWidth = controlWidth,
    })
end

function components.DrawCheckboxControl(draw, data, control)
    draw.widgets.checkbox(data.get(control.alias), {
        label = control.label,
        tooltip = control.helpText,
    })
end

function components.DrawRoomRow(draw, data, definitions, catalog, def)
    local imgui = draw.imgui
    if not def then
        draw.widgets.text("Missing room definition", {
            color = { 0.65, 0.65, 0.65, 1.0 },
        })
        return
    end

    local labelColumnX = 36
    local dropdownColumnX = 160
    local rangeColumnX = 310
    local modeValues, modeDisplayValues = buildEncodedModeOptions(definitions, def)

    components.DrawFixedLabel(draw, def.label, labelColumnX)
    imgui.SetCursorPosX(dropdownColumnX)
    draw.widgets.dropdown(data.get(def.modeKey), {
        label = "",
        values = modeValues,
        displayValues = modeDisplayValues,
        controlWidth = 120,
    })

    if catalog.GetModeValue(function(key)
        return data.get(key):read()
    end, def) == "forced" then
        imgui.SameLine()
        imgui.SetCursorPosX(rangeColumnX)
        components.DrawRangeDropdowns(draw, data, def.rangeMinAlias, def.rangeMaxAlias, def.minDefault, def.maxDefault)
    end
end

function components.DrawRoomSection(draw, data, definitions, catalog, biomeKey, section)
    local imgui = draw.imgui
    local drewSection = false
    local biomeDefinitions = catalog.biomeDefinitions and catalog.biomeDefinitions[biomeKey] or {}

    for _, roomType in ipairs(section.types or {}) do
        for _, def in ipairs(biomeDefinitions[roomType] or {}) do
            if not drewSection then
                components.DrawSectionHeading(draw, section.label, section.color)
                drewSection = true
            end
            components.DrawRoomRow(draw, data, definitions, catalog, def)
        end
    end

    if drewSection then
        imgui.Spacing()
    end
    return drewSection
end

function components.DrawPlaceholder(draw, region)
    draw.widgets.text(region)
    draw.widgets.separator()
    draw.widgets.text("No controls are available for this tab.", {
        color = { 0.65, 0.65, 0.65, 1.0 },
    })
end

return components
