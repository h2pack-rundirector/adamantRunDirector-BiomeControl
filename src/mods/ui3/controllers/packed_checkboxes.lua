local deps = ...
local components = deps.components

local packedCheckboxes = {}

function packedCheckboxes.draw(draw, state, controller, opts)
    components.DrawPackedCheckboxes(draw, state, controller, opts)
end

return packedCheckboxes
