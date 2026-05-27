local deps = ...
local components = deps.components

local range = {}

function range.draw(draw, state, controller)
    components.DrawRange(draw, state, controller)
end

return range
