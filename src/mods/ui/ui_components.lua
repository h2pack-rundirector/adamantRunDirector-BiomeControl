local components = {}

function components.DrawSectionHeading(ctx, text, color)
    ctx.widgets.text(text, { color = color })
    ctx.widgets.separator()
end

function components.DrawFixedLabel(ctx, label, width)
    local imgui = ctx.imgui
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

function components.DrawRangeDropdowns(ctx, minAlias, maxAlias, minValue, maxValue)
    local imgui = ctx.imgui
    local session = ctx.session
    local values = components.BuildIntegerValues(minValue, maxValue)

    ctx.widgets.text("from:", { alignToFramePadding = true })
    imgui.SameLine()
    local minChanged = ctx.widgets.dropdown(minAlias, {
        label = "",
        values = values,
        controlWidth = 60,
    })

    imgui.SameLine()
    ctx.widgets.text("to", { alignToFramePadding = true })
    imgui.SameLine()
    local maxChanged = ctx.widgets.dropdown(maxAlias, {
        label = "",
        values = values,
        controlWidth = 60,
    })

    local currentMin = tonumber(session.view[minAlias]) or minValue
    local currentMax = tonumber(session.view[maxAlias]) or maxValue
    if currentMin > currentMax then
        if minChanged and not maxChanged then
            session.write(maxAlias, currentMin)
        else
            session.write(minAlias, currentMax)
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

function components.DrawModeRow(ctx, catalog, alias, label, controlWidth)
    local entry = catalog.modeEntryLookup[alias]
    local modeValues = {}
    local modeDisplayValues = {}

    for index, value in ipairs(entry and entry.modeValues or {}) do
        local encoded = index - 1
        modeValues[#modeValues + 1] = encoded
        modeDisplayValues[encoded] = entry.modeDisplayValues[value] or tostring(value)
    end

    ctx.widgets.dropdown(alias, {
        label = label or (entry and entry.label) or alias,
        tooltip = entry and entry.helpText or nil,
        values = modeValues,
        displayValues = modeDisplayValues,
        labelWidth = 160,
        controlWidth = controlWidth,
    })
end

function components.DrawCheckboxControl(ctx, control)
    ctx.widgets.checkbox(control.alias, {
        label = control.label,
        tooltip = control.helpText,
    })
end

function components.DrawRoomRow(ctx, definitions, catalog, def)
    local imgui = ctx.imgui
    local session = ctx.session
    if not def then
        ctx.widgets.text("Missing room definition", {
            color = { 0.65, 0.65, 0.65, 1.0 },
        })
        return
    end

    local labelColumnX = 36
    local dropdownColumnX = 160
    local rangeColumnX = 310
    local modeValues, modeDisplayValues = buildEncodedModeOptions(definitions, def)

    components.DrawFixedLabel(ctx, def.label, labelColumnX)
    imgui.SetCursorPosX(dropdownColumnX)
    ctx.widgets.dropdown(def.modeKey, {
        label = "",
        values = modeValues,
        displayValues = modeDisplayValues,
        controlWidth = 120,
    })

    if catalog.GetModeValue(function(key)
        return session.view[key]
    end, def) == "forced" then
        imgui.SameLine()
        imgui.SetCursorPosX(rangeColumnX)
        components.DrawRangeDropdowns(ctx, def.rangeMinAlias, def.rangeMaxAlias, def.minDefault, def.maxDefault)
    end
end

function components.DrawRoomSection(ctx, definitions, catalog, biomeKey, section)
    local imgui = ctx.imgui
    local drewSection = false
    local biomeDefinitions = catalog.biomeDefinitions and catalog.biomeDefinitions[biomeKey] or {}

    for _, roomType in ipairs(section.types or {}) do
        for _, def in ipairs(biomeDefinitions[roomType] or {}) do
            if not drewSection then
                components.DrawSectionHeading(ctx, section.label, section.color)
                drewSection = true
            end
            components.DrawRoomRow(ctx, definitions, catalog, def)
        end
    end

    if drewSection then
        imgui.Spacing()
    end
    return drewSection
end

function components.DrawPlaceholder(ctx, region)
    ctx.widgets.text(region)
    ctx.widgets.separator()
    ctx.widgets.text("No controls are available for this tab.", {
        color = { 0.65, 0.65, 0.65, 1.0 },
    })
end

return components
