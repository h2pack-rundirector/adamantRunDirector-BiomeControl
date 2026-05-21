local module = {}
local definitions
local catalog
local components

local SPECIAL_HEADING_COLOR = { 1.0, 0.60, 0.28, 1.0 }

function module.draw(draw, data)
    local imgui = draw.imgui
    components.DrawRoomSection(draw, data, definitions, catalog, "H", components.SECTION_MINIBOSSES)

    local specials = catalog.biomeSpecials.H or {}
    if #specials > 0 then
        components.DrawSectionHeading(draw, "Special", SPECIAL_HEADING_COLOR)
        for index, control in ipairs(specials) do
            if index > 1 then
                imgui.Spacing()
            end
            components.DrawCheckboxControl(draw, data, control)
        end
    end
    return true
end

function module.bind(deps)
    definitions = deps.definitions
    catalog = deps.catalog
    components = deps.components
    return module
end

return module
