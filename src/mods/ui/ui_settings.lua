local deps = ...
local module = {}
local godAvailability = deps.godAvailability
local uiShared = deps.uiShared

local style = {
    colors = {
        routeRewardHeading = { 0.90, 0.82, 0.56, 1.0 },
        trialRewardHeading = { 0.70, 0.84, 0.96, 1.0 },
    },
    opts = {
        prioritizeSpecificReward = {
            label = "Choose First Boon in Each Biome",
        },
        prioritizeTrialReward = {
            label = "Choose Boon Priorities in Trial Rooms",
        },
        godChoice = {
            labelWidth = 160,
            controlWidth = 180,
        },
        resetAllSettings = {
            confirmLabel = "Confirm Reset All",
        },
    },
}
local PRIORITIZE_SPECIFIC_REWARD_CONTROL = "PrioritizeSpecificRewardEnabled"
local PRIORITIZE_TRIAL_REWARD_CONTROL = "PrioritizeTrialRewardEnabled"

local function drawGodChoice(ui, name)
    local control = ui.controls.get(name)
    control:refreshVisibility(godAvailability.availableGods(ui.data))
    ui.draw.control(control, "default", style.opts.godChoice)
end

function module.draw(ui)
    local draw = ui.draw
    local imgui = draw.imgui

    uiShared.DrawSectionHeading(draw, "Route Reward Priorities", style.colors.routeRewardHeading)
    draw.control(ui.controls.get(PRIORITIZE_SPECIFIC_REWARD_CONTROL), "default", style.opts.prioritizeSpecificReward)

    if ui.controls.read("PrioritizeSpecificRewardEnabled") == true then
        drawGodChoice(ui, "PriorityBiome1")
        drawGodChoice(ui, "PriorityBiome2")
        drawGodChoice(ui, "PriorityBiome3")
        drawGodChoice(ui, "PriorityBiome4")
    end

    imgui.Spacing()
    uiShared.DrawSectionHeading(draw, "Trial Reward Priorities", style.colors.trialRewardHeading)
    draw.control(ui.controls.get(PRIORITIZE_TRIAL_REWARD_CONTROL), "default", style.opts.prioritizeTrialReward)

    if ui.controls.read("PrioritizeTrialRewardEnabled") == true then
        drawGodChoice(ui, "PriorityTrial1")
        drawGodChoice(ui, "PriorityTrial2")
    end

    imgui.Spacing()
    draw.widgets.separator()
    imgui.Spacing()
    if draw.widgets.confirmButton("biome_control_reset_all_settings", "Reset All Controls", style.opts.resetAllSettings) then
        ui.resetAll()
    end
end

return module
