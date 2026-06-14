local deps = ...
local module = {}
local biomeUis = {}
local uiShared = deps.uiShared
local resolver = deps.resolver

local biomeStyle = {
    colors = {
        room = { 0.90, 0.82, 0.56, 1.0 },
        miniboss = { 0.88, 0.38, 0.32, 1.0 },
        rewards = { 0.70, 0.84, 0.96, 1.0 },
        special = { 1.0, 0.60, 0.28, 1.0 },
    },
    opts = {
        roomController = {
            labelWidth = 160,
            controlWidth = 180,
            rangeColumnX = 390,
        },
        godChoice = {
            labelWidth = 160,
            controlWidth = 180,
        },
    },
}
biomeStyle.roomControllerOpts = uiShared.BuildLabeledOpts(biomeStyle.opts.roomController)

local biomeDeps = {
    biomeStyle = biomeStyle,
    uiShared = uiShared,
    resolver = resolver,
}

for _, moduleInfo in ipairs(resolver.biomeUiModules()) do
    biomeUis[moduleInfo.biomeKey] = import(moduleInfo.path, nil, biomeDeps)
end

function module.draw(ui, biomeKey)
    local biomeUi = biomeUis[biomeKey]
    if biomeUi and biomeUi.draw(ui) then
        return
    end
end

return module
