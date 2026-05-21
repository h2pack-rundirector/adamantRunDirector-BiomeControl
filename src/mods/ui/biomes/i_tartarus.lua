local module = {}
local definitions
local catalog
local components

local MINIBOSS_SECTION = {
    label = "Minibosses",
    color = { 0.88, 0.38, 0.32, 1.0 },
    types = { "MiniBoss" },
}

function module.draw(draw, data)
    return components.DrawRoomSection(draw, data, definitions, catalog, "I", MINIBOSS_SECTION)
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
