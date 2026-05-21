local module = {}
local catalog
local components

local function BindDraw()
    local NPC_MODE_DEFAULT = 0
    local NPC_MODE_DISABLED = 1
    local NPC_MODE_FORCED = 2
    local NPC_MODE_VALUES = {
        NPC_MODE_DEFAULT,
        NPC_MODE_DISABLED,
        NPC_MODE_FORCED,
    }
    local NPC_MODE_DISPLAY_VALUES = {
        [NPC_MODE_DEFAULT] = "Default",
        [NPC_MODE_DISABLED] = "Disabled",
        [NPC_MODE_FORCED] = "Forced",
    }
    local NPC_SPACING_VALUES = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }
    local NPC_GROUP_COLORS = {
        Artemis = { 15 / 255, 255 / 255, 9 / 255, 1.0 },
        Nemesis = { 115 / 255, 146 / 255, 210 / 255, 1.0 },
        Athena = { 255 / 255, 216 / 255, 60 / 255, 1.0 },
        Heracles = { 255 / 255, 125 / 255, 25 / 255, 1.0 },
        Icarus = { 243 / 255, 215 / 255, 116 / 255, 1.0 },
    }

    local function BuildRegionBiomeKeyLookup(region)
        local keys = {}
        for _, biome in ipairs(catalog.biomeTabs or {}) do
            if biome.region == region then
                keys[biome.key] = true
            end
        end
        return keys
    end

    local function DrawNpcBiomeRow(draw, data, def)
        local imgui = draw.imgui
        local modeField = data.get(def.modeKey)
        local labelColumnX = 36
        local dropdownColumnX = 160
        local rangeColumnX = 310

        imgui.Indent(16)
        components.DrawFixedLabel(draw, def.region, labelColumnX)
        imgui.SetCursorPosX(dropdownColumnX)
        draw.widgets.dropdown(modeField, {
            label = "",
            values = NPC_MODE_VALUES,
            displayValues = NPC_MODE_DISPLAY_VALUES,
            controlWidth = 120,
        })

        if modeField:read() == NPC_MODE_FORCED then
            imgui.SameLine()
            imgui.SetCursorPosX(rangeColumnX)
            components.DrawRangeDropdowns(draw, data, def.rangeMinAlias, def.rangeMaxAlias, def.minDefault, def.maxDefault)
        end
        imgui.Unindent(16)
    end

    local function DrawNpcGroup(draw, data, group)
        local color = NPC_GROUP_COLORS[group.actualNPCName] or { 0.90, 0.82, 0.56, 1.0 }
        draw.widgets.text(group.label, { color = color })
        for _, def in ipairs(group.definitions or {}) do
            DrawNpcBiomeRow(draw, data, def)
        end
    end

    local function DrawNpcRules(draw, data)
        local imgui = draw.imgui
        imgui.Spacing()
        components.DrawSectionHeading(draw, "NPC Rules", { 0.70, 0.84, 0.96, 1.0 })
        draw.widgets.checkbox(data.get("OnlyAllowForcedEncounters"), {
            label = "Only Allow Forced NPC Encounters",
            tooltip = "Blocks NPC encounters left on Default. Only Forced entries can appear.",
        })
        draw.widgets.text("Blocks NPC encounters left on Default. Only Forced entries can appear.", {
            color = { 0.65, 0.65, 0.65, 1.0 },
        })
        draw.widgets.checkbox(data.get("IgnoreMaxDepth"), {
            label = "Ignore NPC Max Depth Requirements",
            tooltip = "Forced NPC encounters can still appear after max depth.",
        })
        draw.widgets.text("Forced NPC encounters can still appear after max depth.", {
            color = { 0.65, 0.65, 0.65, 1.0 },
        })
        draw.widgets.dropdown(data.get("NPCSpacing"), {
            label = "Minimum rooms between field NPC encounters",
            values = NPC_SPACING_VALUES,
            controlWidth = 60,
        })
    end

    function module.drawRegion(draw, data, region)
        local imgui = draw.imgui
        components.DrawSectionHeading(draw, "NPCs", { 0.90, 0.82, 0.56, 1.0 })
        local drewAny = false
        local regionBiomeKeys = BuildRegionBiomeKeyLookup(region)
        for _, groupId in ipairs(catalog.npcGroups and catalog.npcGroups.orderedIds or {}) do
            local group = catalog.npcGroups[groupId]
            local regionDefinitions = {}
            for _, def in ipairs(group and group.definitions or {}) do
                if def.region == region or regionBiomeKeys[def.biome] then
                    regionDefinitions[#regionDefinitions + 1] = def
                end
            end
            if #regionDefinitions > 0 then
                if drewAny then
                    imgui.Separator()
                end
                DrawNpcGroup(draw, data, {
                    label = group.label,
                    actualNPCName = group.actualNPCName,
                    definitions = regionDefinitions,
                })
                drewAny = true
            end
        end
        DrawNpcRules(draw, data)
    end
end

function module.bind(deps)
    catalog = deps.catalog
    components = deps.components
    BindDraw()
    return module
end

return module
