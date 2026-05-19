local module = {}
local definitions
local catalog
local components

local MINIBOSS_SECTION = {
    label = "Minibosses",
    color = { 0.88, 0.38, 0.32, 1.0 },
    types = { "MiniBoss" },
}

function module.draw(ctx)
    local imgui = ctx.imgui
    components.DrawRoomSection(ctx, definitions, catalog, "H", MINIBOSS_SECTION)

    local specials = catalog.biomeSpecials.H or {}
    if #specials > 0 then
        components.DrawSectionHeading(ctx, "Special", { 1.0, 0.60, 0.28, 1.0 })
        for index, control in ipairs(specials) do
            if index > 1 then
                imgui.Spacing()
            end
            components.DrawCheckboxControl(ctx, control)
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
