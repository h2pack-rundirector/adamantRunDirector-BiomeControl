local roomPatches = {}

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

function roomPatches.forceRoomBetweenRange(plan, def, roomKey, minValue, maxValue, extraValues)
    local room = getRoomData(def, roomKey)
    if not room then return false end

    local values = {
        ForceAtBiomeDepthMin = minValue,
        ForceAtBiomeDepthMax = maxValue,
    }
    if extraValues then
        for key, value in pairs(extraValues) do
            values[key] = value
        end
    end

    plan:setMany(room, values)
    applyBiomeDepthRequirements(plan, room, minValue, maxValue)
    return true
end

function roomPatches.disableRoom(plan, def, roomKey)
    local room = getRoomData(def, roomKey)
    if not room then return false end

    plan:appendUnique(room, "GameStateRequirements", {
        Path = { "CurrentRun", "BiomeDepthCache" },
        Comparison = "==",
        Value = -1,
    })
    return true
end

function roomPatches.preventRoomReward(plan, def, roomKey, rewardName)
    local room = getRoomData(def, roomKey)
    if not room then return false end

    plan:appendUnique(room, "IneligibleRewards", rewardName)
    return true
end

function roomPatches.patchForceOrDisableRoom(plan, runtime, info)
    local control = runtime.controls.get(info.controlName)
    local mode = control:mode()
    if mode == "forced" then
        local minValue, maxValue = control:range()
        roomPatches.forceRoomBetweenRange(plan, info, info.roomKey, minValue, maxValue)
    elseif mode == "disabled" then
        roomPatches.disableRoom(plan, info, info.roomKey)
    end
end

return roomPatches
