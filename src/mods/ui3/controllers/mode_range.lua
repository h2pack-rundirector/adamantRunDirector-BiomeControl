local deps = ...
local components = deps.components

local modeRange = {}

function modeRange.draw(draw, state, controller, opts)
    components.DrawModeRange(draw, state, controller, opts)
end

return modeRange
