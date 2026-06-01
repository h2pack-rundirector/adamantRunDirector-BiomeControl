local deps = ...
local controlDefs = deps.controlDefs

local rewardPriority = {}

function rewardPriority.build()
    return {
        controlDefs.flag("PrioritizeSpecificRewardEnabled", {
            label = "Prioritize Specific Rewards",
            helpText = "(Before room selection, push selected god rewards to the front when available)",
        }),
        controlDefs.godChoice("PriorityBiome1", {
            label = "Biome 1 Choice",
        }),
        controlDefs.godChoice("PriorityBiome2", {
            label = "Biome 2 Choice",
        }),
        controlDefs.godChoice("PriorityBiome3", {
            label = "Biome 3 Choice",
        }),
        controlDefs.godChoice("PriorityBiome4", {
            label = "Biome 4 Choice",
        }),
        controlDefs.flag("PrioritizeTrialRewardEnabled", {
            label = "Prioritize Trial Rewards",
            helpText = "(Before room selection, push selected trial rewards to the front when available)",
        }),
        controlDefs.godChoice("PriorityTrial1", {
            label = "Trial Choice A",
        }),
        controlDefs.godChoice("PriorityTrial2", {
            label = "Trial Choice B",
        }),
    }
end

return rewardPriority
