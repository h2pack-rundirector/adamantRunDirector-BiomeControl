local deps = ...
local components = deps.components

local dropdown = {}

function dropdown.draw(draw, state, controller, opts)
    components.DrawDropdown(draw, state, controller, opts)
end

return dropdown
