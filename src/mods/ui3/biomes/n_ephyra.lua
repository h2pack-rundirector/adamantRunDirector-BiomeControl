local deps = ...
local module = {}
local catalog = deps.catalog
local components = deps.components

local ROOM_COLOR = { 0.90, 0.82, 0.56, 1.0 }
local MINIBOSS_COLOR = { 0.88, 0.38, 0.32, 1.0 }
local REWARDS_COLOR = { 0.70, 0.84, 0.96, 1.0 }

local STORY_MODE_OPTS = {
    labelWidth = 160,
    controlWidth = 150,
}

local MINIBOSS_MODE_OPTS = {
    labelWidth = 160,
    controlWidth = 250,
}

local REWARD_DROPDOWN_OPTS = {
    labelWidth = 160,
    controlWidth = 180,
}

local function drawRewardList(draw, state, controller)
    draw.imgui.Spacing()
    components.DrawController(draw, state, controller)
end

function module.draw(draw, state)
    local biome = catalog.biomes.N
    local controls = biome.controls
    local imgui = draw.imgui

    components.DrawSectionHeading(draw, "Rooms", ROOM_COLOR)
    components.DrawController(draw, state, controls.EphyraStoryMode.controller, STORY_MODE_OPTS)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Minibosses", MINIBOSS_COLOR)
    components.DrawController(draw, state, controls.EphyraMiniBossMode.controller, MINIBOSS_MODE_OPTS)

    imgui.Spacing()

    components.DrawSectionHeading(draw, "Rewards", REWARDS_COLOR)
    components.DrawController(draw, state, controls.ReplaceHermesInEphyra.controller, REWARD_DROPDOWN_OPTS)
    drawRewardList(draw, state, controls.PackedBannedEphyraSubRoomRewards.controller)
    drawRewardList(draw, state, controls.PackedBannedEphyraSubRoomRewardsHard.controller)
    return true
end

return module
