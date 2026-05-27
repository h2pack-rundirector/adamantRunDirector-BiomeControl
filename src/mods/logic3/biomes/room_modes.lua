local deps = ...
local module = {}
local catalog = deps.catalog
local controllerReader = deps.controllerReader

local function appendDefinitions(target, source)
    for _, def in ipairs(source or {}) do
        target[#target + 1] = def
    end
end

local function buildRoomDefinitions()
    local definitions = {}
    for _, biome in ipairs(catalog.biomes.ordered or {}) do
        appendDefinitions(definitions, biome.roomOrder)
        appendDefinitions(definitions, biome.minibossOrder)
    end
    return definitions
end

local function getRoomKey(def)
    if def.roomKey and def.roomKey ~= "" then
        return def.roomKey
    end
    if def.type == "Story" then
        return def.biome .. "_Story01"
    end
    if def.type == "Fountain" then
        return def.biome .. "_Reprieve01"
    end
    if def.type == "Shop" then
        return def.biome .. "_Shop01"
    end
    if def.type == "Trial" and def.biome == "O" then
        return "O_Devotion01"
    end
end

local function getRoomData(def, roomKey)
    if RoomData and RoomData[roomKey] then
        return RoomData[roomKey]
    end
    local roomSet = RoomSetData and RoomSetData[def.biome]
    if roomSet then
        return roomSet[roomKey]
    end
end

local function applyBiomeDepthRequirements(plan, room, minValue, maxValue)
    if not room or not room.GameStateRequirements then return end

    plan:transform(room, "GameStateRequirements", function(requirements)
        local changed = false
        local copy = {}
        for i, requirement in ipairs(requirements or {}) do
            if type(requirement) == "table" and
                requirement.Path and requirement.Path[1] == "CurrentRun" and
                requirement.Path[2] == "BiomeDepthCache" then
                local requirementCopy = {}
                for reqKey, reqValue in pairs(requirement) do
                    requirementCopy[reqKey] = reqValue
                end

                if requirement.Comparison == ">=" and requirement.Value ~= minValue then
                    requirementCopy.Value = minValue
                    changed = true
                elseif requirement.Comparison == "<=" and requirement.Value ~= maxValue then
                    requirementCopy.Value = maxValue
                    changed = true
                end

                copy[i] = requirementCopy
            else
                copy[i] = requirement
            end
        end
        for key, value in pairs(requirements or {}) do
            if type(key) ~= "number" then
                copy[key] = value
            end
        end
        return changed and copy or requirements
    end)
end

local function applyRangeOverride(plan, def, roomKey, minValue, maxValue)
    local room = getRoomData(def, roomKey)
    if not room then return end
    plan:setMany(room, {
        ForceAtBiomeDepthMin = minValue,
        ForceAtBiomeDepthMax = maxValue,
    })
    applyBiomeDepthRequirements(plan, room, minValue, maxValue)
end

local function disableRoom(plan, def, roomKey)
    local room = getRoomData(def, roomKey)
    if not room then return end

    plan:appendUnique(room, "GameStateRequirements", {
        Path = { "CurrentRun", "BiomeDepthCache" },
        Comparison = "==",
        Value = -1,
    })
end

local roomDefinitions = buildRoomDefinitions()

function module.buildPatchPlan(plan, _, store)
    for _, def in ipairs(roomDefinitions) do
        local roomKey = getRoomKey(def)
        if roomKey then
            local mode = controllerReader.readMode(store, def.controller)
            if mode == "forced" then
                local minValue, maxValue = controllerReader.readRange(store, def.controller)
                applyRangeOverride(plan, def, roomKey, minValue, maxValue)
            elseif mode == "disabled" then
                disableRoom(plan, def, roomKey)
            end
        end
    end
end

return module
