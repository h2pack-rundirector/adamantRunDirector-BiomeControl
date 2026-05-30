local module = {}
local definitions
local catalog
local components

function module.draw(draw, state)
    local drewRooms = components.DrawRoomSection(draw, state, definitions, catalog, "G", components.SECTION_ROOMS)
    local drewMinibosses = components.DrawRoomSection(draw, state, definitions, catalog, "G",
        components.SECTION_MINIBOSSES)
    return drewRooms or drewMinibosses
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
