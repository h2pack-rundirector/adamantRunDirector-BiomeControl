local module = {}
local definitions
local catalog
local components
local rewardControlOptsByAlias
local rewardLabelOptsByAlias
local rewardPackedOptsByAlias

local REWARDS_HEADING_COLOR = { 0.70, 0.84, 0.96, 1.0 }

local function getRewardControl(kindOrAlias)
    for _, control in ipairs(catalog.biomeRewards.N or {}) do
        if control.kind == kindOrAlias or control.alias == kindOrAlias then
            return control
        end
    end
end

local function drawHubReplacement(draw, data, control)
    if not control then return end

    draw.widgets.dropdown(data.get(control.alias), rewardControlOptsByAlias[control.alias])
end

local function drawPackedRewardList(draw, data, control)
    if not control then return end

    draw.imgui.Spacing()
    draw.widgets.text(control.label, rewardLabelOptsByAlias[control.alias])
    draw.widgets.packedCheckboxList(data.get(control.alias), rewardPackedOptsByAlias[control.alias])
end

local function drawEphyraRewards(draw, data)
    components.DrawSectionHeading(draw, "Rewards", REWARDS_HEADING_COLOR)
    drawHubReplacement(draw, data, getRewardControl("field"))
    drawPackedRewardList(draw, data, getRewardControl("PackedBannedEphyraSubRoomRewards"))
    drawPackedRewardList(draw, data, getRewardControl("PackedBannedEphyraSubRoomRewardsHard"))
end

function module.draw(draw, data)
    local imgui = draw.imgui
    components.DrawSectionHeading(draw, components.SECTION_ROOMS.label, components.SECTION_ROOMS.color)
    components.DrawModeRow(draw, data, catalog, "EphyraStoryMode", nil, 150)

    imgui.Spacing()
    components.DrawSectionHeading(draw, components.SECTION_MINIBOSSES.label, components.SECTION_MINIBOSSES.color)
    components.DrawModeRow(draw, data, catalog, "EphyraMiniBossMode", nil, 250)

    imgui.Spacing()
    drawEphyraRewards(draw, data)
    return true
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    local hubRewardReplacementOptions = { "" }
    local hubRewardReplacementDisplayValues = {
        [""] = "Hermes (Default)",
    }
    for _, god in ipairs(definitions.priorityGods or {}) do
        hubRewardReplacementOptions[#hubRewardReplacementOptions + 1] = god.lootKey
        hubRewardReplacementDisplayValues[god.lootKey] = god.label
    end

    rewardControlOptsByAlias = {}
    rewardLabelOptsByAlias = {}
    rewardPackedOptsByAlias = {}
    for _, control in ipairs(catalog.biomeRewards.N or {}) do
        if control.kind == "field" then
            rewardControlOptsByAlias[control.alias] = {
                label = control.label or "Hub Hermes Replacement",
                tooltip = control.helpText,
                values = hubRewardReplacementOptions,
                displayValues = hubRewardReplacementDisplayValues,
                labelWidth = 160,
                controlWidth = 180,
            }
        end
        rewardLabelOptsByAlias[control.alias] = {
            tooltip = control.helpText,
        }
        rewardPackedOptsByAlias[control.alias] = {
            slotCount = #(control.options or {}),
        }
    end
    return module
end

return module
