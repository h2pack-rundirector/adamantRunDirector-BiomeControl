local deps = ...
local module = {}
local definitions = deps.definitions
local components = deps.components
local godAvailability = deps.godAvailability

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
local PRIORITIZE_SPECIFIC_REWARD_SETTING = { name = "PrioritizeSpecificRewardEnabled" }
local PRIORITIZE_TRIAL_REWARD_SETTING = { name = "PrioritizeTrialRewardEnabled" }

local function isGodPoolFilteringActive(state)
    return godAvailability and godAvailability.isActive(state) == true
end

local function clearTable(target)
    for key in pairs(target) do
        target[key] = nil
    end
end

local function isPriorityLootAvailable(state, lootKey)
    if lootKey == "" then
        return true
    end

    local godKey = priorityGodByLootKey[lootKey]
    if not godKey then
        return true
    end

    return not godAvailability or godAvailability.isAvailable(state, godKey)
end

local function buildPriorityOptions(state)
    if not isGodPoolFilteringActive(state) then
        return priorityOptions
    end

    local values = {}
    for _, value in ipairs(priorityOptions) do
        if isPriorityLootAvailable(state, value) then
            values[#values + 1] = value
        end
    end
    return values
end

local function drawPriorityDropdown(draw, state, alias, opts, values)
    opts.values = values
    draw.widgets.dropdown(state.get(alias), opts)
end

local function bindPriorityOptions()
    clearTable(priorityOptions)
    clearTable(priorityDisplayValues)
    clearTable(priorityValueColors)
    clearTable(priorityGodByLootKey)
    priorityOptions[1] = ""
    priorityDisplayValues[""] = "None"

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
end

function module.draw(ui)
    local draw = ui.draw
    local state = ui.data
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Route Reward Priorities", ROUTE_REWARD_HEADING_COLOR)
    components.DrawSetting(ui, PRIORITIZE_SPECIFIC_REWARD_SETTING, prioritizeSpecificRewardOpts)

    if ui.controls.read("PrioritizeSpecificRewardEnabled") == true then
        local availablePriorityOptions = buildPriorityOptions(state)
        drawPriorityDropdown(draw, state, "PriorityBiome1", priorityBiome1Opts, availablePriorityOptions)
        drawPriorityDropdown(draw, state, "PriorityBiome2", priorityBiome2Opts, availablePriorityOptions)
        drawPriorityDropdown(draw, state, "PriorityBiome3", priorityBiome3Opts, availablePriorityOptions)
        drawPriorityDropdown(draw, state, "PriorityBiome4", priorityBiome4Opts, availablePriorityOptions)
    end

    imgui.Spacing()
    components.DrawSectionHeading(draw, "Trial Reward Priorities", TRIAL_REWARD_HEADING_COLOR)
    components.DrawSetting(ui, PRIORITIZE_TRIAL_REWARD_SETTING, prioritizeTrialRewardOpts)

    if ui.controls.read("PrioritizeTrialRewardEnabled") == true then
        local availablePriorityOptions = buildPriorityOptions(state)
        drawPriorityDropdown(draw, state, "PriorityTrial1", priorityTrial1Opts, availablePriorityOptions)
        drawPriorityDropdown(draw, state, "PriorityTrial2", priorityTrial2Opts, availablePriorityOptions)
    end

    imgui.Spacing()
    draw.widgets.separator()
    imgui.Spacing()
    resetAllSettingsOpts.action = ui.actions.get("resetAll")
    draw.widgets.confirmButton("biome_control_reset_all_settings", "Reset All Controls", resetAllSettingsOpts)
end

bindPriorityOptions()

return module
