local deps = ...
local module = {}
local biomeStyle = deps.biomeStyle
local uiShared = deps.uiShared
local resolver = deps.resolver

local function drawRewardList(ui, controlName)
    ui.draw.imgui.Spacing()
    ui.draw.control(ui.controls.get(controlName))
end

function module.draw(ui)
    local draw = ui.draw
    local imgui = draw.imgui

    uiShared.DrawSectionHeading(draw, "Rooms", biomeStyle.colors.room)
    draw.control(ui.controls.get(resolver.control("N", "EphyraStoryMode")), "default", biomeStyle.opts.roomController)

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Minibosses", biomeStyle.colors.miniboss)
    draw.control(ui.controls.get(resolver.control("N", "EphyraMiniBossMode")), "default", biomeStyle.opts.roomController)

    imgui.Spacing()

    uiShared.DrawSectionHeading(draw, "Rewards", biomeStyle.colors.rewards)
    draw.control(ui.controls.get(resolver.control("N", "ReplaceHermesInEphyra")), "default", biomeStyle.opts.godChoice)
    drawRewardList(ui, resolver.control("N", "PackedBannedEphyraSubRoomRewards"))
    drawRewardList(ui, resolver.control("N", "PackedBannedEphyraSubRoomRewardsHard"))
    return true
end

return module
