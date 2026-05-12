local module = {}
local biomeUis = {}
local components

function module.draw(imgui, session, biomeKey)
    local biomeUi = biomeUis[biomeKey]
    if biomeUi and biomeUi.draw(imgui, session) then
        return
    end
    components.DrawPlaceholder(imgui, biomeKey)
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
