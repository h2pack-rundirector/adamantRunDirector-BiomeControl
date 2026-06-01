local module = {}

local function updateDreamBiomePool(route, slot)
    CurrentRun.DreamBiomePool = {}
    for index = slot + 1, #route do
        CurrentRun.DreamBiomePool[#CurrentRun.DreamBiomePool + 1] = route[index]
    end
end

function module.registerHooks(moduleRef)
    moduleRef.hooks.wrap("SelectNextDreamBiome", function(host, runtime, base, currentRoomSet)
        if not host.isEnabled() then return base(currentRoomSet) end
        if not CurrentRun or not CurrentRun.IsDreamRun or not CurrentRun.CurrentRoom then
            return base(currentRoomSet)
        end

        local dreamRoute = runtime.controls.get("DreamRoute")
        local route = dreamRoute:route()
        if not route then return base(currentRoomSet) end

        local slot = (CurrentRun.EnteredBiomes or 0) + 1
        local nextRoomSet = dreamRoute:biomeAt(slot)
        if not nextRoomSet then return base(currentRoomSet) end
        if dreamRoute:isNaturalNext(currentRoomSet, nextRoomSet) then
            return base(currentRoomSet)
        end

        CurrentRun.CurrentRoom.NextRoomSet = { nextRoomSet }
        if slot == 1 then
            GameState.LastDreamStartingBiome = nextRoomSet
        end
        updateDreamBiomePool(route, slot)
    end)
end

return module
