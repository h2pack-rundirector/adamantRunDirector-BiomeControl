local module = {}
local catalog
local CreateStoreReader

local function BindLogic()
    local roomDefinitions = catalog.roomDefinitions

    local function GetDefinitionMode(read, def)
        return catalog.GetModeValue(read, def)
    end

    local function GetRoomKey(def)
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

    local function GetRoomData(def, roomKey)
        if RoomData and RoomData[roomKey] then
            return RoomData[roomKey]
        end
        local roomSet = RoomSetData and RoomSetData[def.biome]
        if roomSet then
            return roomSet[roomKey]
        end
    end

    local function ApplyBiomeDepthRequirements(plan, room, minValue, maxValue)
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

    local function ApplyRangeOverride(plan, def, roomKey, minValue, maxValue)
        local room = GetRoomData(def, roomKey)
        if not room then return end
        plan:setMany(room, {
            ForceAtBiomeDepthMin = minValue,
            ForceAtBiomeDepthMax = maxValue,
        })
        ApplyBiomeDepthRequirements(plan, room, minValue, maxValue)
    end

    local function DisableRoom(plan, def, roomKey)
        local room = GetRoomData(def, roomKey)
        if not room then return end

        plan:appendUnique(room, "GameStateRequirements", {
            Path = { "CurrentRun", "BiomeDepthCache" },
            Comparison = "==",
            Value = -1,
        })
    end

    function module.buildPatchPlan(plan, _, store)
        local read = CreateStoreReader(store)
        for _, def in ipairs(roomDefinitions) do
            local roomKey = GetRoomKey(def)
            if roomKey then
                local mode = GetDefinitionMode(read, def)
                if mode == "forced" then
                    ApplyRangeOverride(
                        plan,
                        def,
                        roomKey,
                        read(def.rangeMinAlias),
                        read(def.rangeMaxAlias)
                    )
                elseif mode == "disabled" then
                    DisableRoom(plan, def, roomKey)
                end
            end
        end
    end
end

function module.bind(deps)
    catalog = deps.catalog
    CreateStoreReader = deps.CreateStoreReader
    BindLogic()
    return module
end

return module
