local deps = ...
local module = {}
local resolver = deps.resolver
local roomPatches = deps.roomPatches

local function applyThessalyMiniboss(plan, runtime, log)
    local info = {
        biome = "O",
    }
    local control = runtime.controls.get("ThessalyMiniBossMode")
    local mode = control:mode()
    if mode == "default" then
        return
    end

    if mode == "disabled" then
        roomPatches.disableRoom(plan, info, "O_MiniBoss01")
        roomPatches.disableRoom(plan, info, "O_MiniBoss02")
        log("Disabled both Thessaly miniboss rooms")
        return
    end

    local minValue, maxValue = control:range()
    if minValue > maxValue then
        maxValue = minValue
    end

    if mode == "charybdis" then
        roomPatches.forceRoomBetweenRange(plan, info, "O_MiniBoss01", minValue, maxValue, {
            AlwaysForce = true,
        })
        roomPatches.disableRoom(plan, info, "O_MiniBoss02")
        log("Forced Thessaly Charybdis miniboss")
    elseif mode == "captain" then
        roomPatches.forceRoomBetweenRange(plan, info, "O_MiniBoss02", minValue, maxValue, {
            AlwaysForce = true,
        })
        roomPatches.disableRoom(plan, info, "O_MiniBoss01")
        log("Forced Thessaly The Yargonaut miniboss")
    end
end

function module.buildPatchPlan(host, runtime, plan)
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("O", "Circe"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("O", "Trial"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("O", "Fountain"))
    roomPatches.patchForceOrDisableRoom(plan, runtime, resolver.roomInfo("O", "Shop"))
    applyThessalyMiniboss(plan, runtime, host.logIf)
end

return module
