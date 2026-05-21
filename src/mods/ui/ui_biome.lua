local module = {}
local biomeUis = {}
local components

function module.draw(draw, data, biomeKey)
    local biomeUi = biomeUis[biomeKey]
    if biomeUi and biomeUi.draw(draw, data) then
        return
    end
    components.DrawPlaceholder(draw, biomeKey)
end

function module.bind(deps)
    components = deps.components
    biomeUis = {}

    local biomeDeps = {
        definitions = deps.definitions,
        catalog = deps.catalog,
        components = components,
    }

    for _, biome in ipairs(deps.catalog.biomes or {}) do
        if biome.ui then
            biomeUis[biome.key] = import(biome.ui).bind(biomeDeps)
        end
    end

    return module
end

return module
