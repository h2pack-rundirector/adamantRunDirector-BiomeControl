local module = {}
local definitions
local components

local function BindDraw()
    local PRIORITY_LABEL_WIDTH = 160
    local GOD_AVAILABILITY_INTEGRATION = "run-director.god-availability"
    local priorityOptions = { "" }
    local priorityDisplayValues = { [""] = "None" }
    local priorityValueColors = {}
    local priorityGodByLootKey = {}

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

    local function IsGodPoolFilteringActive()
        return lib.integrations.invoke(GOD_AVAILABILITY_INTEGRATION, "isActive", false) == true
    end

    local function IsPriorityLootAvailable(lootKey)
        if lootKey == "" then
            return true
        end

        local godKey = priorityGodByLootKey[lootKey]
        if not godKey then
            return true
        end

        return lib.integrations.invoke(GOD_AVAILABILITY_INTEGRATION, "isAvailable", true, godKey) ~= false
    end

    local function BuildPriorityOptions()
        if not IsGodPoolFilteringActive() then
            return priorityOptions
        end

        local values = {}
        for _, value in ipairs(priorityOptions) do
            if IsPriorityLootAvailable(value) then
                values[#values + 1] = value
            end
        end
        return values
    end

    function module.draw(ctx)
        local imgui = ctx.imgui
        local session = ctx.session

        components.DrawSectionHeading(ctx, "Route Reward Priorities", { 0.90, 0.82, 0.56, 1.0 })
        ctx.widgets.checkbox("PrioritizeSpecificRewardEnabled", {
            label = "Choose First Boon in Each Biome",
        })

        if session.view["PrioritizeSpecificRewardEnabled"] == true then
            local availablePriorityOptions = BuildPriorityOptions()
            ctx.widgets.dropdown("PriorityBiome1", {
                label = "Biome 1 Choice",
                values = availablePriorityOptions,
                displayValues = priorityDisplayValues,
                valueColors = priorityValueColors,
                labelWidth = PRIORITY_LABEL_WIDTH,
                controlWidth = 180,
            })
            ctx.widgets.dropdown("PriorityBiome2", {
                label = "Biome 2 Choice",
                values = availablePriorityOptions,
                displayValues = priorityDisplayValues,
                valueColors = priorityValueColors,
                labelWidth = PRIORITY_LABEL_WIDTH,
                controlWidth = 180,
            })
            ctx.widgets.dropdown("PriorityBiome3", {
                label = "Biome 3 Choice",
                values = availablePriorityOptions,
                displayValues = priorityDisplayValues,
                valueColors = priorityValueColors,
                labelWidth = PRIORITY_LABEL_WIDTH,
                controlWidth = 180,
            })
            ctx.widgets.dropdown("PriorityBiome4", {
                label = "Biome 4 Choice",
                values = availablePriorityOptions,
                displayValues = priorityDisplayValues,
                valueColors = priorityValueColors,
                labelWidth = PRIORITY_LABEL_WIDTH,
                controlWidth = 180,
            })
        end

        imgui.Spacing()
        components.DrawSectionHeading(ctx, "Trial Reward Priorities", { 0.70, 0.84, 0.96, 1.0 })
        ctx.widgets.checkbox("PrioritizeTrialRewardEnabled", {
            label = "Choose Boon Priorities in Trial Rooms",
        })

        if session.view["PrioritizeTrialRewardEnabled"] == true then
            local availablePriorityOptions = BuildPriorityOptions()
            ctx.widgets.dropdown("PriorityTrial1", {
                label = "Trial Choice A",
                values = availablePriorityOptions,
                displayValues = priorityDisplayValues,
                valueColors = priorityValueColors,
                labelWidth = PRIORITY_LABEL_WIDTH,
                controlWidth = 180,
            })
            ctx.widgets.dropdown("PriorityTrial2", {
                label = "Trial Choice B",
                values = availablePriorityOptions,
                displayValues = priorityDisplayValues,
                valueColors = priorityValueColors,
                labelWidth = PRIORITY_LABEL_WIDTH,
                controlWidth = 180,
            })
        end

        imgui.Spacing()
        ctx.widgets.separator()
        imgui.Spacing()
        ctx.widgets.confirmButton("biome_control_reset_all_settings", "Reset All Controls", {
            confirmLabel = "Confirm Reset All",
            onConfirm = function()
                session.resetToDefaults()
            end,
        })
    end
end

function module.bind(deps)
    definitions = deps.definitions
    components = deps.components
    BindDraw()
    return module
end

return module
