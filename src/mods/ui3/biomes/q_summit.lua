local deps = ...
local module = {}
local components = deps.components

function module.draw(draw)
    components.DrawPlaceholder(draw, "Summit")
    return false
end

return module
