local module = {}
local definitions
local catalog
local components

function module.draw(draw, data)
    local drewRooms = components.DrawRoomSection(draw, data, definitions, catalog, "F", components.SECTION_ROOMS)
    local drewMinibosses = components.DrawRoomSection(draw, data, definitions, catalog, "F",
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
