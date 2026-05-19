local module = {}
local definitions
local catalog
local components

local function getRewardControl(kindOrAlias)
    for _, control in ipairs(catalog.biomeRewards.N or {}) do
        if control.kind == kindOrAlias or control.alias == kindOrAlias then
            return control
        end
    end
end

local function drawHubReplacement(ctx, control)
    if not control then return end

    local hubRewardReplacementOptions = { "" }
    local hubRewardReplacementDisplayValues = {
        [""] = "Hermes (Default)",
    }

    for _, god in ipairs(definitions.priorityGods or {}) do
        hubRewardReplacementOptions[#hubRewardReplacementOptions + 1] = god.lootKey
        hubRewardReplacementDisplayValues[god.lootKey] = god.label
    end

    ctx.widgets.dropdown(control.alias, {
        label = control.label or "Hub Hermes Replacement",
        tooltip = control.helpText,
        values = hubRewardReplacementOptions,
        displayValues = hubRewardReplacementDisplayValues,
        labelWidth = 160,
        controlWidth = 180,
    })
end

local function drawPackedRewardList(ctx, control)
    if not control then return end

    ctx.imgui.Spacing()
    ctx.widgets.text(control.label, {
        tooltip = control.helpText,
    })
    ctx.widgets.packedCheckboxList(control.alias, {
        slotCount = #(control.options or {}),
    })
end

local function drawEphyraRewards(ctx)
    components.DrawSectionHeading(ctx, "Rewards", { 0.70, 0.84, 0.96, 1.0 })
    drawHubReplacement(ctx, getRewardControl("field"))
    drawPackedRewardList(ctx, getRewardControl("PackedBannedEphyraSubRoomRewards"))
    drawPackedRewardList(ctx, getRewardControl("PackedBannedEphyraSubRoomRewardsHard"))
end

function module.draw(ctx)
    local imgui = ctx.imgui
    components.DrawSectionHeading(ctx, "Rooms", { 0.90, 0.82, 0.56, 1.0 })
    components.DrawModeRow(ctx, catalog, "EphyraStoryMode", nil, 150)

    imgui.Spacing()
    components.DrawSectionHeading(ctx, "Minibosses", { 0.88, 0.38, 0.32, 1.0 })
    components.DrawModeRow(ctx, catalog, "EphyraMiniBossMode", nil, 250)

    imgui.Spacing()
    drawEphyraRewards(ctx)
    return true
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
