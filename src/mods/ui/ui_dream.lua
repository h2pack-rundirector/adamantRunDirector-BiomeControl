local deps = ...
local module = {}
local uiShared = deps.uiShared

local style = {
    colors = {
        heading = { 0.72, 0.80, 1.0, 1.0 },
    },
}

function module.draw(ui)
    local draw = ui.draw

    uiShared.DrawSectionHeading(draw, "Dream Route", style.colors.heading)
    draw.control(ui.controls.get("DreamRoute"))
end

return module
