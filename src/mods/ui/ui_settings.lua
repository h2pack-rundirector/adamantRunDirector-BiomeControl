local module = {}
local definitions
local components
local godAvailability

local function BindDraw()
    local PRIORITY_LABEL_WIDTH = 160
    local ROUTE_REWARD_HEADING_COLOR = { 0.90, 0.82, 0.56, 1.0 }
    local TRIAL_REWARD_HEADING_COLOR = { 0.70, 0.84, 0.96, 1.0 }
    local priorityOptions = { "" }
    local priorityDisplayValues = { [""] = "None" }
    local priorityValueColors = {}
    local priorityGodByLootKey = {}
    local prioritizeSpecificRewardOpts = {
        label = "Choose First Boon in Each Biome",
    }
    local prioritizeTrialRewardOpts = {
        label = "Choose Boon Priorities in Trial Rooms",
    }
    local priorityBiome1Opts = {
        label = "Biome 1 Choice",
        values = priorityOptions,
        displayValues = priorityDisplayValues,
        valueColors = priorityValueColors,
        labelWidth = PRIORITY_LABEL_WIDTH,
        controlWidth = 180,
    }
    local priorityBiome2Opts = {
        label = "Biome 2 Choice",
        values = priorityOptions,
        displayValues = priorityDisplayValues,
        valueColors = priorityValueColors,
        labelWidth = PRIORITY_LABEL_WIDTH,
        controlWidth = 180,
    }
    local priorityBiome3Opts = {
        label = "Biome 3 Choice",
        values = priorityOptions,
        displayValues = priorityDisplayValues,
        valueColors = priorityValueColors,
        labelWidth = PRIORITY_LABEL_WIDTH,
        controlWidth = 180,
    }
    local priorityBiome4Opts = {
        label = "Biome 4 Choice",
        values = priorityOptions,
        displayValues = priorityDisplayValues,
        valueColors = priorityValueColors,
        labelWidth = PRIORITY_LABEL_WIDTH,
        controlWidth = 180,
    }
    local priorityTrial1Opts = {
        label = "Trial Choice A",
        values = priorityOptions,
        displayValues = priorityDisplayValues,
        valueColors = priorityValueColors,
        labelWidth = PRIORITY_LABEL_WIDTH,
        controlWidth = 180,
    }
    local priorityTrial2Opts = {
        label = "Trial Choice B",
        values = priorityOptions,
        displayValues = priorityDisplayValues,
        valueColors = priorityValueColors,
        labelWidth = PRIORITY_LABEL_WIDTH,
        controlWidth = 180,
    }
    local resetAllSettingsOpts = {
        confirmLabel = "Confirm Reset All",
    }

    for _, god in ipairs(definitions.priorityGods or {}) do
        priorityOptions[#priorityOptions + 1] = god.lootKey
        priorityDisplayValues[god.lootKey] = god.label
        priorityGodByLootKey[god.lootKey] = god.label
        local inGameColor = god.colorKey and game.Color[god.colorKey] or nil
        if type(inGameColor) == "table" then
            priorityValueColors[god.lootKey] = {
                inGameColor[1] / 255,
                inGameColor[2] / 255,
                inGameColor[3] / 255,
                inGameColor[4] / 255,
            }
        end
    end

    local function IsGodPoolFilteringActive(services)
        return godAvailability.isActive(services)
    end

    local function IsPriorityLootAvailable(services, lootKey)
        if lootKey == "" then
            return true
        end

        local godKey = priorityGodByLootKey[lootKey]
        if not godKey then
            return true
        end

        return godAvailability.isAvailable(services, godKey)
    end

    local function BuildPriorityOptions(services)
        if not IsGodPoolFilteringActive(services) then
            return priorityOptions
        end

        local values = {}
        for _, value in ipairs(priorityOptions) do
            if IsPriorityLootAvailable(services, value) then
                values[#values + 1] = value
            end
        end
        return values
    end

    local function DrawPriorityDropdown(draw, state, alias, opts, values)
        opts.values = values
        draw.widgets.dropdown(state.get(alias), opts)
    end

    function module.draw(draw, state, actions, services)
        local imgui = draw.imgui

        components.DrawSectionHeading(draw, "Route Reward Priorities", ROUTE_REWARD_HEADING_COLOR)
        draw.widgets.checkbox(state.get("PrioritizeSpecificRewardEnabled"), prioritizeSpecificRewardOpts)

        if state.get("PrioritizeSpecificRewardEnabled"):read() == true then
            local availablePriorityOptions = BuildPriorityOptions(services)
            DrawPriorityDropdown(draw, state, "PriorityBiome1", priorityBiome1Opts, availablePriorityOptions)
            DrawPriorityDropdown(draw, state, "PriorityBiome2", priorityBiome2Opts, availablePriorityOptions)
            DrawPriorityDropdown(draw, state, "PriorityBiome3", priorityBiome3Opts, availablePriorityOptions)
            DrawPriorityDropdown(draw, state, "PriorityBiome4", priorityBiome4Opts, availablePriorityOptions)
        end

        imgui.Spacing()
        components.DrawSectionHeading(draw, "Trial Reward Priorities", TRIAL_REWARD_HEADING_COLOR)
        draw.widgets.checkbox(state.get("PrioritizeTrialRewardEnabled"), prioritizeTrialRewardOpts)

        if state.get("PrioritizeTrialRewardEnabled"):read() == true then
            local availablePriorityOptions = BuildPriorityOptions(services)
            DrawPriorityDropdown(draw, state, "PriorityTrial1", priorityTrial1Opts, availablePriorityOptions)
            DrawPriorityDropdown(draw, state, "PriorityTrial2", priorityTrial2Opts, availablePriorityOptions)
        end

        imgui.Spacing()
        draw.widgets.separator()
        imgui.Spacing()
        resetAllSettingsOpts.action = actions.get("resetAll")
        draw.widgets.confirmButton("biome_control_reset_all_settings", "Reset All Controls", resetAllSettingsOpts)
    end
end

function module.bind(deps)
    definitions = deps.definitions
    components = deps.components
    godAvailability = deps.godAvailability
    BindDraw()
    return module
end

return module
