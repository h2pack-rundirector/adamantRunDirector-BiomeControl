local deps = ...
local components = deps.components

local mode = {}

function mode.draw(draw, state, controller, opts)
    components.DrawMode(draw, state, controller, opts)
end

return mode
