local deps = ...
local module = {}
local components = deps.components

function module.draw(ui)
    components.DrawPlaceholder(ui.draw, "Summit")
    return false
end

return module
