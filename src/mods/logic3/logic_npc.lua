local deps = ...
local module = {}
local catalog = deps.catalog
local GetRunState = deps.GetRunState
local controllerReader = deps.controllerReader

local npcPriorityList = { "Artemis", "Icarus", "Heracles", "Athena", "Nemesis" }
local forcePattern = "[FGHINOPQ]$"
local strictPattern = "[FGHINOPQ]0?2?$"

local function buildNpcLookup()
    local lookup = {}
    for _, groupKey in ipairs(catalog.npcs.orderedIds or {}) do
        local group = catalog.npcs[groupKey]
        local actualNPCName = group and group.actualNPCName
        if actualNPCName then
            lookup[actualNPCName] = lookup[actualNPCName] or {}
            for _, def in ipairs(group.definitions or {}) do
                lookup[actualNPCName][def.biome] = def
            end
        end
    end
    return lookup
end

local npcLookup = buildNpcLookup()

local function getCurrentNPCRange(store, def)
    return controllerReader.readRange(store, def.controller)
end

function module.buildPatchPlan(plan, _, store)
    if NamedRequirementsData.NoRecentFieldNPCEncounter and NamedRequirementsData.NoRecentFieldNPCEncounter[1] then
        plan:set(NamedRequirementsData.NoRecentFieldNPCEncounter[1], "SumPrevRooms", store.read("NPCSpacing") or 6)
    end
end

function module.registerHooks(host, store)
    host.hooks.wrap("ChooseEncounter", function(base, currentRun, room, args)
        if not host.isEnabled() then return base(currentRun, room, args) end

        args = args or {}
        local legalEncounters = args.LegalEncounters or room.LegalEncounters
        if not legalEncounters then return base(currentRun, room, args) end

        local state = GetRunState(store)
        if not state then return base(currentRun, room, args) end

        local currentRoomSet = room and room.RoomSetName
        local biomeDepth = currentRun.BiomeDepthCache or 0
        local encounterSeen = state.NPCEncounterSeen or {}
        local pending = state.ForcedNPCPending or {}

        for _, groupKey in ipairs(catalog.npcs.orderedIds or {}) do
            local group = catalog.npcs[groupKey]
            local actualNPCName = group.actualNPCName
            local perPending = pending[groupKey]
            if perPending and currentRoomSet and perPending[currentRoomSet] and not encounterSeen[actualNPCName] then
                local def = group.lookup and group.lookup[currentRoomSet]
                if def then
                    local minValue, maxValue = getCurrentNPCRange(store, def)
                    local depthOkay = biomeDepth >= minValue and (store.read("IgnoreMaxDepth") or biomeDepth <= maxValue)
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
                            local def = npcLookup[npcName] and npcLookup[npcName][currentRoomSet]
                            if def then
                                local perPending = pending[def.groupKey]
                                local mode = controllerReader.readMode(store, def.controller)
                                local minValue, maxValue = getCurrentNPCRange(store, def)
                                if mode == "disabled" then
                                    restricted = true
                                elseif mode ~= "forced" then
                                    restricted = true
                                elseif not (perPending and currentRoomSet and perPending[currentRoomSet]) then
                                    restricted = true
                                elseif biomeDepth < minValue then
                                    restricted = true
                                elseif not store.read("IgnoreMaxDepth") and biomeDepth > maxValue then
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
        host.hooks.wrap("Begin" .. npcName .. "Encounter", function(base, currentRun, room, args)
            if host.isEnabled() then
                local state = GetRunState(store)
                if state then
                    state.NPCEncounterSeen[npcName] = true
                end
            end
            return base(currentRun, room, args)
        end)
    end
end

return module
