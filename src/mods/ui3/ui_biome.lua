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
    if biome.ui3 then
        biomeUis[biome.key] = import(biome.ui3, nil, biomeDeps)
    end
end

function module.draw(draw, state, biomeKey)
    local biomeUi = biomeUis[biomeKey]
    if biomeUi and biomeUi.draw(draw, state) then
        return
    end
    components.DrawPlaceholder(draw, biomeKey)
end

return module
