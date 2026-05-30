local module = {}
local definitions
local catalog
local components

function module.draw(draw, state)
    return components.DrawRoomSection(draw, state, definitions, catalog, "I", components.SECTION_MINIBOSSES)
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
