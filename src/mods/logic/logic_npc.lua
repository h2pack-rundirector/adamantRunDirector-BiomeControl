local deps = ...
local module = {}
local resolver = deps.resolver
local GetRunState = deps.GetRunState

local npcPriorityList = { "Artemis", "Icarus", "Heracles", "Athena", "Nemesis" }
local forcePattern = "[FGHINOPQ]$"
local strictPattern = "[FGHINOPQ]0?2?$"

local function getCurrentNPCRange(runtime, def)
    return runtime.controls.get(def.controlName):range()
end

function module.buildPatchPlan(_, runtime, plan)
    if NamedRequirementsData.NoRecentFieldNPCEncounter and NamedRequirementsData.NoRecentFieldNPCEncounter[1] then
        plan:set(NamedRequirementsData.NoRecentFieldNPCEncounter[1], "SumPrevRooms",
            runtime.controls.read("NPCSpacing") or 6)
    end
end

function module.registerHooks(moduleRef)
    moduleRef.hooks.wrap("ChooseEncounter", function(host, runtime, base, currentRun, room, args)
        if not host.isEnabled() then return base(currentRun, room, args) end

        args = args or {}
        local legalEncounters = args.LegalEncounters or room.LegalEncounters
        if not legalEncounters then return base(currentRun, room, args) end

        local state = GetRunState(runtime)
        if not state then return base(currentRun, room, args) end

        local currentRoomSet = room and room.RoomSetName
        local biomeDepth = currentRun.BiomeDepthCache or 0
        local encounterSeen = state.NPCEncounterSeen or {}
        local pending = state.ForcedNPCPending or {}

        for _, group in ipairs(resolver.npcGroups()) do
            local actualNPCName = group.actualNPCName
            local perPending = pending[group.id]
            if perPending and currentRoomSet and perPending[currentRoomSet] and not encounterSeen[actualNPCName] then
                local def = resolver.npcInfo(group.id, currentRoomSet)
                if def then
                    local minValue, maxValue = getCurrentNPCRange(runtime, def)
                    local depthOkay = biomeDepth >= minValue and
                        (runtime.controls.read("IgnoreMaxDepth") or biomeDepth <= maxValue)
                    if depthOkay then
                        for _, encounterName in ipairs(legalEncounters) do
                            if type(encounterName) == "string"
                                and encounterName:find(actualNPCName, 1, true)
                                and encounterName:find("Combat", 1, true)
                                and encounterName:find(forcePattern) then
                                local encData = EncounterData and EncounterData[encounterName]
                                local eligible = true
                                if encData and encData.GameStateRequirements then
                                    eligible = IsGameStateEligible(encData, encData.GameStateRequirements, args)
                                        and IsEncounterEligible(currentRun, room, encData, args)
                                end
                                if eligible then
                                    args.LegalEncounters = { encounterName }
                                    return base(currentRun, room, args)
                                end
                            end
                        end
                    end
                end
            end
        end

        if state.OnlyAllowForcedEncounters then
            local filtered = {}
            local changed = false

            for _, encounterName in ipairs(legalEncounters) do
                local restricted = false
                if type(encounterName) == "string"
                    and encounterName:find(strictPattern)
                    and encounterName:find("Combat", 1, true) then
                    for _, npcName in ipairs(npcPriorityList) do
                        if encounterName:find(npcName, 1, true) then
                            local def = resolver.npcInfoByActualName(npcName, currentRoomSet)
                            if def then
                                local perPending = pending[def.groupKey]
                                local control = runtime.controls.get(def.controlName)
                                local mode = control:mode()
                                local minValue, maxValue = control:range()
                                if mode == "disabled" then
                                    restricted = true
                                elseif mode ~= "forced" then
                                    restricted = true
                                elseif not (perPending and currentRoomSet and perPending[currentRoomSet]) then
                                    restricted = true
                                elseif biomeDepth < minValue then
                                    restricted = true
                                elseif not runtime.controls.read("IgnoreMaxDepth") and biomeDepth > maxValue then
                                    restricted = true
                                end
                            elseif state.OnlyAllowForcedEncounters then
                                restricted = true
                            end
                            break
                        end
                    end
                end

                if restricted then
                    changed = true
                else
                    table.insert(filtered, encounterName)
                end
            end

            if changed then
                args.LegalEncounters = filtered
            end
        end

        return base(currentRun, room, args)
    end)

    for _, npcName in ipairs(npcPriorityList) do
        moduleRef.hooks.wrap("Begin" .. npcName .. "Encounter", function(host, runtime, base, currentRun, room, args)
            if host.isEnabled() then
                local state = GetRunState(runtime)
                if state then
                    state.NPCEncounterSeen[npcName] = true
                end
            end
            return base(currentRun, room, args)
        end)
    end
end

return module
