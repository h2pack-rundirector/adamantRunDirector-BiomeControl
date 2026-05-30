local module = {}

local function preventEchoScam(plan, runtime)
    if not runtime.controls.read("PreventEchoScam") then return end

    local depthRequirement = {
        Path = { "CurrentRun", "BiomeDepthCache" },
        Comparison = "!=",
        Value = 3,
    }

    for _, roomKey in ipairs({ "H_MiniBoss01", "H_MiniBoss02" }) do
        if RoomData and RoomData[roomKey] then
            plan:appendUnique(RoomData[roomKey], "GameStateRequirements", depthRequirement)
        end
    end
end

function module.buildPatchPlan(_, runtime, plan)
    preventEchoScam(plan, runtime)
end

function module.registerHooks(moduleRef)
    moduleRef.hooks.wrap("SelectFieldsDoorCageCount", function(host, runtime, base, run, room)
        if not host.isEnabled() then
            return base(run, room)
        end

        if not runtime.controls.read("ForceTwoRewardFieldsOpeners") then
            return base(run, room)
        end

        local biomeDepth = run and tonumber(run.BiomeDepthCache) or 0
        local roomName = room and room.Name or nil

        if biomeDepth <= 2 and type(roomName) == "string" and roomName:match("^H_Combat%d+$") then
            return room.MinDoorCageRewards or 2
        end

        return base(run, room)
    end)
end

return module
