local module = {}
local definitions
local catalog
local components

local ROOM_SECTION = {
    label = "Rooms",
    color = { 0.90, 0.82, 0.56, 1.0 },
    types = { "Story", "Fountain", "Shop" },
}

local MINIBOSS_SECTION = {
    label = "Minibosses",
    color = { 0.88, 0.38, 0.32, 1.0 },
    types = { "MiniBoss" },
}

function module.draw(draw, data)
    local drewRooms = components.DrawRoomSection(draw, data, definitions, catalog, "P", ROOM_SECTION)
    local drewMinibosses = components.DrawRoomSection(draw, data, definitions, catalog, "P", MINIBOSS_SECTION)
    return drewRooms or drewMinibosses
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
