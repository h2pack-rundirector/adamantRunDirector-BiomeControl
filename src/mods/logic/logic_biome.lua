local module = {}
local roomModes
local biomeLogic = {}

local function BindLogic()
    function module.buildPatchPlan(plan, host, store)
        if roomModes.buildPatchPlan then
            roomModes.buildPatchPlan(plan, host, store)
        end
        for _, logic in ipairs(biomeLogic) do
            if logic.buildPatchPlan then
                logic.buildPatchPlan(plan, host, store)
            end
        end
    end

    function module.registerHooks(host, store)
        for _, logic in ipairs(biomeLogic) do
            if logic.registerHooks then
                logic.registerHooks(host, store)
            end
        end
    end
end

function module.bind(deps)
    roomModes = import("mods/logic/biomes/room_modes.lua").bind(deps)
    biomeLogic = {}
    for _, biome in ipairs(deps.catalog.biomes or {}) do
        if biome.logic then
            biomeLogic[#biomeLogic + 1] = import(biome.logic).bind(deps)
        end
    end
    BindLogic()
    return module
end

return module
