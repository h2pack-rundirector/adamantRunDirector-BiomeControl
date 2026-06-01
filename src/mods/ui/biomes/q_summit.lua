local deps = ...
local module = {}
local uiShared = deps.uiShared

function module.draw(ui)
    ui.draw.widgets.text("Summit")
    ui.draw.widgets.separator()
    uiShared.DrawMutedText(ui.draw, "No controls are available for this tab.")
end

return module
