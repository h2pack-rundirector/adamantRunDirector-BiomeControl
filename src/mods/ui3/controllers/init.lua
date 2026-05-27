local deps = ...
local components = deps.components

local controllers = {}
local controllerDeps = {
    components = components,
    controllers = controllers,
}

local mode = import("mods/ui3/controllers/mode.lua", nil, controllerDeps)
local range = import("mods/ui3/controllers/range.lua", nil, controllerDeps)
local modeRange = import("mods/ui3/controllers/mode_range.lua", nil, controllerDeps)
local checkbox = import("mods/ui3/controllers/checkbox.lua", nil, controllerDeps)
local dropdown = import("mods/ui3/controllers/dropdown.lua", nil, controllerDeps)
local packedCheckboxes = import("mods/ui3/controllers/packed_checkboxes.lua", nil, controllerDeps)

local renderersByPrimitive = {
    storyModeRange = modeRange.draw,
    trialModeRange = modeRange.draw,
    roomModeRange = modeRange.draw,
    minibossDepth = modeRange.draw,
    npcModeRange = modeRange.draw,
    modeRange = modeRange.draw,
    minibossSelector = mode.draw,
    mode = mode.draw,
    forcedMinibossRange = range.draw,
    range = range.draw,
    checkbox = checkbox.draw,
    dropdown = dropdown.draw,
    packedCheckboxes = packedCheckboxes.draw,
}

controllers.GetModeValue = components.GetModeValue
controllers.DrawSectionHeading = components.DrawSectionHeading
controllers.DrawPlaceholder = components.DrawPlaceholder
controllers.DrawFixedLabel = components.DrawFixedLabel

function controllers.DrawController(draw, state, controller, opts)
    if not controller then
        components.DrawMutedText(draw, "Missing controller")
        return
    end

    local renderer = renderersByPrimitive[controller.primitive]
    if renderer then
        renderer(draw, state, controller, opts)
    elseif controller.bindings.mode and controller.bindings.range then
        modeRange.draw(draw, state, controller, opts)
    elseif controller.bindings.mode then
        mode.draw(draw, state, controller, opts)
    elseif controller.bindings.range then
        range.draw(draw, state, controller)
    elseif controller.bindings.value then
        if controller.bindings.value.type == "bool" then
            checkbox.draw(draw, state, controller, opts)
        else
            dropdown.draw(draw, state, controller, opts)
        end
    elseif controller.bindings.packed then
        packedCheckboxes.draw(draw, state, controller, opts)
    end
end

return controllers
