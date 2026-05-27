local deps = ...
local module = {}
local catalog = deps.catalog
local controllerReader = deps.controllerReader

local function appendImpossibleRequirement(plan, roomKey)
    local room = RoomData and RoomData[roomKey]
    if not room then return end
    plan:appendUnique(room, "GameStateRequirements", {
        Path = { "CurrentRun", "BiomeDepthCache" },
        Comparison = "==",
        Value = -1,
    })
end

local function applyBiomeDepthRange(plan, roomKey, minValue, maxValue)
    local room = RoomData and RoomData[roomKey]
    if not room then return end

    plan:setMany(room, {
        ForceAtBiomeDepthMin = minValue,
        ForceAtBiomeDepthMax = maxValue,
        AlwaysForce = true,
    })

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

local function applyThessalyMiniboss(plan, store, log)
    local controls = catalog.biomes.O.controls
    local mode = controllerReader.readMode(store, controls.ThessalyMiniBossMode.controller)
    if mode == "default" then
        return
    end

    if mode == "disabled" then
        appendImpossibleRequirement(plan, "O_MiniBoss01")
        appendImpossibleRequirement(plan, "O_MiniBoss02")
        log("Disabled both Thessaly miniboss rooms")
        return
    end

    local minValue, maxValue = controllerReader.readRange(store, controls.ForcedThessalyMiniBoss.controller)
    if minValue > maxValue then
        maxValue = minValue
    end

    if mode == "charybdis" then
        applyBiomeDepthRange(plan, "O_MiniBoss01", minValue, maxValue)
        appendImpossibleRequirement(plan, "O_MiniBoss02")
        log("Forced Thessaly Charybdis miniboss")
    elseif mode == "captain" then
        applyBiomeDepthRange(plan, "O_MiniBoss02", minValue, maxValue)
        appendImpossibleRequirement(plan, "O_MiniBoss01")
        log("Forced Thessaly The Yargonaut miniboss")
    end
end

function module.buildPatchPlan(plan, host, store)
    applyThessalyMiniboss(plan, store, host.logIf)
end

return module
