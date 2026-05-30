local deps = ...
local module = {}
local biomeUis = {}
local catalog = deps.catalog
local components = deps.components

local biomeDeps = {
    catalog = catalog,
    components = components,
}

for _, biome in ipairs(catalog.biomes or {}) do
    if biome.ui then
        biomeUis[biome.key] = import(biome.ui, nil, biomeDeps)
    end
end

function module.draw(ui, biomeKey)
    local biomeUi = biomeUis[biomeKey]
    if biomeUi and biomeUi.draw(ui) then
        return
    end
    components.DrawPlaceholder(ui.draw, biomeKey)
end

return module
