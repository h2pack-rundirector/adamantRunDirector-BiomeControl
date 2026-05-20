local module = {}

local function PreventEchoScam(plan, read)
    if not read("PreventEchoScam") then return end

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

function module.buildPatchPlan(plan, _, store)
    PreventEchoScam(plan, store.read)
end

function module.registerHooks(host, store)
    host.hooks.wrap("SelectFieldsDoorCageCount", function(base, run, room)
        if not host.isEnabled() then
            return base(run, room)
        end

        if not store.read("ForceTwoRewardFieldsOpeners") then
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

function module.bind()
    return module
end

return module
