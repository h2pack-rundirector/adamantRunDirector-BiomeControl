local deps = ...
local settings = deps.settings

local controls = {}

function controls.build()
    return {
        settings.flag("OnlyAllowForcedEncounters", {
            label = "Only Allow Forced Encounters",
            helpText = "(When enabled, non-forced special rooms are suppressed)",
        }),
        settings.flag("IgnoreMaxDepth", {
            label = "Ignore Max Depth",
            helpText = "(Allow configured rooms past their normal maximum depth)",
        }),
        settings.choice("NPCSpacing", {
            label = "NPC Spacing",
            type = "int",
            values = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 },
            default = 6,
            min = 1,
            max = 12,
            helpText = "(Minimum depth spacing between forced NPC encounters)",
        }),
        settings.flag("PrioritizeSpecificRewardEnabled", {
            label = "Prioritize Specific Rewards",
            helpText = "(Before room selection, push selected god rewards to the front when available)",
        }),
        settings.flag("PrioritizeTrialRewardEnabled", {
            label = "Prioritize Trial Rewards",
            helpText = "(Before room selection, push selected trial rewards to the front when available)",
        }),
    }
end

return controls
