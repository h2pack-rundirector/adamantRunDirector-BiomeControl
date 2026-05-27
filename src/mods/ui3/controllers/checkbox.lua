local deps = ...
local components = deps.components

local checkbox = {}

function checkbox.draw(draw, state, controller, opts)
    components.DrawCheckbox(draw, state, controller, opts)
end

return checkbox
