local lu = require("luaunit")

TestBiomeControlLogic = {}

function TestBiomeControlLogic:testPatchPlanAddsRoomAndNpcMutations()
    local harness = ResetBiomeControlHarness({
        controls = {
            StoryArachne = { mode = "forced", min = 5, max = 7 },
            MiniBossTreant = { mode = "disabled" },
            NPCSpacing = 9,
            PreventEchoScam = true,
        },
    })

    harness.applyPatchPlan()

    lu.assertEquals(RoomData.F_Story01.ForceAtBiomeDepthMin, 5)
    lu.assertEquals(RoomData.F_Story01.ForceAtBiomeDepthMax, 7)
    lu.assertEquals(RoomData.F_Story01.GameStateRequirements[1].Value, 5)
    lu.assertEquals(RoomData.F_Story01.GameStateRequirements[2].Value, 7)
    lu.assertEquals(#RoomData.F_MiniBoss01.GameStateRequirements, 1)
    lu.assertEquals(RoomData.F_MiniBoss01.GameStateRequirements[1].Value, -1)
    lu.assertEquals(NamedRequirementsData.NoRecentFieldNPCEncounter[1].SumPrevRooms, 9)
    lu.assertEquals(#RoomData.H_MiniBoss01.GameStateRequirements, 1)
    lu.assertEquals(RoomData.H_MiniBoss01.GameStateRequirements[1].Value, 3)
end

function TestBiomeControlLogic:testForcedErebusTrialInjectsDevotionReward()
    local harness = ResetBiomeControlHarness({
        controls = {
            TrialErebus = { mode = "forced", min = 7, max = 9 },
        },
        RoomSetData = {
            F = {
                F_Combat05 = { Name = "F_Combat05" },
            },
        },
    })

    harness.applyPatchPlan()

    lu.assertEquals(RoomSetData.F.F_Combat05.ForcedReward, "Devotion")
    lu.assertEquals(RoomSetData.F.F_Combat05.ForceAtBiomeDepthMin, 7)
    lu.assertEquals(RoomSetData.F.F_Combat05.ForceAtBiomeDepthMax, 9)
end

function TestBiomeControlLogic:testForcedOceanusTrialInjectsDevotionReward()
    local harness = ResetBiomeControlHarness({
        controls = {
            TrialOceanus = { mode = "forced", min = 4, max = 6 },
        },
        RoomSetData = {
            G = {
                G_Combat02 = { Name = "G_Combat02" },
            },
        },
    })

    harness.applyPatchPlan()

    lu.assertEquals(RoomSetData.G.G_Combat02.ForcedReward, "Devotion")
    lu.assertEquals(RoomSetData.G.G_Combat02.ForceAtBiomeDepthMin, 4)
    lu.assertEquals(RoomSetData.G.G_Combat02.ForceAtBiomeDepthMax, 6)
end

function TestBiomeControlLogic:testDisabledErebusTrialSuppressesDevotionReward()
    local harness = ResetBiomeControlHarness({
        controls = {
            TrialErebus = { mode = "disabled" },
        },
        RoomSetData = {
            F = {
                F_Combat05 = { Name = "F_Combat05" },
                F_Combat06 = { Name = "F_Combat06", IneligibleRewards = { "Boon" } },
            },
        },
    })

    harness.applyPatchPlan()

    lu.assertEquals(RoomSetData.F.F_Combat05.IneligibleRewards, { "Devotion" })
    lu.assertEquals(RoomSetData.F.F_Combat06.IneligibleRewards, { "Boon", "Devotion" })
    lu.assertNil(RoomSetData.F.F_Combat05.ForcedReward)
end

function TestBiomeControlLogic:testDisabledOceanusTrialSuppressesDevotionReward()
    local harness = ResetBiomeControlHarness({
        controls = {
            TrialOceanus = { mode = "disabled" },
        },
        RoomSetData = {
            G = {
                G_Combat02 = { Name = "G_Combat02" },
            },
        },
    })

    harness.applyPatchPlan()

    lu.assertEquals(RoomSetData.G.G_Combat02.IneligibleRewards, { "Devotion" })
    lu.assertNil(RoomSetData.G.G_Combat02.ForcedReward)
end

function TestBiomeControlLogic:testBiomePriorityFiltersEligibleLootUntilSatisfied()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            PriorityBiome1 = "ApolloUpgrade",
            PrioritizeSpecificRewardEnabled = true,
        },
        CurrentRun = {
            EnteredBiomes = 1,
        },
        GetEligibleLootNames = function()
            return { "ZeusUpgrade", "ApolloUpgrade" }
        end,
    })

    lu.assertEquals(GetEligibleLootNames({}), { "ApolloUpgrade" })

    GiveLoot({ ForceLootName = "ApolloUpgrade" })
    lu.assertEquals(GetEligibleLootNames({}), { "ZeusUpgrade", "ApolloUpgrade" })
end

function TestBiomeControlLogic:testBiomePriorityUsesCurrentEnteredBiome()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            PriorityBiome1 = "ApolloUpgrade",
            PriorityBiome2 = "ZeusUpgrade",
            PrioritizeSpecificRewardEnabled = true,
        },
        CurrentRun = {
            EnteredBiomes = 2,
        },
        GetEligibleLootNames = function()
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
    })

    lu.assertEquals(GetEligibleLootNames({}), { "ZeusUpgrade" })

    GiveLoot({ ForceLootName = "ZeusUpgrade" })
    lu.assertEquals(GetEligibleLootNames({}), { "ApolloUpgrade", "ZeusUpgrade" })
end

function TestBiomeControlLogic:testBiomePriorityIgnoresGodPoolDisabledChoice()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            PriorityBiome1 = "ApolloUpgrade",
            PrioritizeSpecificRewardEnabled = true,
        },
        godAvailability = {
            available = {
                Apollo = false,
            },
        },
        CurrentRun = {
            EnteredBiomes = 1,
        },
        GetEligibleLootNames = function()
            return { "ZeusUpgrade", "ApolloUpgrade" }
        end,
    })

    lu.assertEquals(GetEligibleLootNames({}), { "ZeusUpgrade", "ApolloUpgrade" })
end

function TestBiomeControlLogic:testTrialRewardPrioritySetsEncounterLootPair()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            PriorityTrial1 = "ApolloUpgrade",
            PriorityTrial2 = "ZeusUpgrade",
            PrioritizeTrialRewardEnabled = true,
        },
        CurrentRun = {},
        GetInteractedGodsThisRun = function()
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
        GetEligibleLootNames = function(excluded)
            if excluded and excluded[1] == "ApolloUpgrade" then
                return { "ZeusUpgrade" }
            end
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
    })

    local room = {
        ChosenRewardType = "Devotion",
        Encounter = {},
    }
    SetupRoomReward(CurrentRun, room, nil, {})

    lu.assertEquals(room.Encounter.LootAName, "ApolloUpgrade")
    lu.assertEquals(room.Encounter.LootBName, "ZeusUpgrade")
end

function TestBiomeControlLogic:testTrialRewardPriorityIgnoresBiomePriorityFilter()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            PriorityBiome1 = "DemeterUpgrade",
            PriorityTrial1 = "ApolloUpgrade",
            PriorityTrial2 = "ZeusUpgrade",
            PrioritizeSpecificRewardEnabled = true,
            PrioritizeTrialRewardEnabled = true,
        },
        CurrentRun = {
            EnteredBiomes = 1,
        },
        GetInteractedGodsThisRun = function()
            return { "ApolloUpgrade", "ZeusUpgrade", "DemeterUpgrade" }
        end,
        GetEligibleLootNames = function(excluded)
            if excluded and excluded[1] == "ApolloUpgrade" then
                return { "ZeusUpgrade", "DemeterUpgrade" }
            end
            return { "ApolloUpgrade", "ZeusUpgrade", "DemeterUpgrade" }
        end,
    })

    lu.assertEquals(GetEligibleLootNames({}), { "DemeterUpgrade" })

    local room = {
        ChosenRewardType = "Devotion",
        Encounter = {},
    }
    SetupRoomReward(CurrentRun, room, nil, {})

    lu.assertEquals(room.Encounter.LootAName, "ApolloUpgrade")
    lu.assertEquals(room.Encounter.LootBName, "ZeusUpgrade")
end

function TestBiomeControlLogic:testTrialRewardPrioritySkipsGodPoolDisabledChoice()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            PriorityTrial1 = "ApolloUpgrade",
            PriorityTrial2 = "ZeusUpgrade",
            PrioritizeTrialRewardEnabled = true,
        },
        godAvailability = {
            available = {
                Apollo = false,
            },
        },
        CurrentRun = {},
        GetInteractedGodsThisRun = function()
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
        GetEligibleLootNames = function(excluded)
            if excluded and excluded[1] == "ApolloUpgrade" then
                return { "ZeusUpgrade" }
            end
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
    })

    local room = {
        ChosenRewardType = "Devotion",
        Encounter = {},
    }
    SetupRoomReward(CurrentRun, room, nil, {})

    lu.assertNil(room.Encounter.LootAName)
    lu.assertNil(room.Encounter.LootBName)
end

function TestBiomeControlLogic:testForcedNpcEncounterNarrowsLegalEncounterList()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            NPCArtemisErebus = { mode = "forced", min = 4, max = 10 },
        },
        CurrentRun = {},
        ChooseEncounter = function(_, _, args)
            return args.LegalEncounters
        end,
    })

    local currentRun = {
        BiomeDepthCache = 4,
    }
    local room = {
        RoomSetName = "F",
        LegalEncounters = {
            "NemesisCombatF",
            "ArtemisCombatF",
        },
    }
    local result = ChooseEncounter(currentRun, room, {})

    lu.assertEquals(result, { "ArtemisCombatF" })
end

function TestBiomeControlLogic:testOnlyAllowForcedEncountersFiltersUnforcedNpcEncounters()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            OnlyAllowForcedEncounters = true,
        },
        CurrentRun = {},
        ChooseEncounter = function(_, _, args)
            return args.LegalEncounters
        end,
    })

    local currentRun = {
        BiomeDepthCache = 4,
    }
    local room = {
        RoomSetName = "F",
        LegalEncounters = {
            "NemesisCombatF",
            "ArtemisCombatF",
            "GenericCombatF",
        },
    }
    local result = ChooseEncounter(currentRun, room, {})

    lu.assertEquals(result, { "GenericCombatF" })
end

function TestBiomeControlLogic:testFieldsTwoRewardHookOverridesEarlyCombatRooms()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            ForceTwoRewardFieldsOpeners = true,
        },
    })

    local result = SelectFieldsDoorCageCount({
        BiomeDepthCache = 2,
    }, {
        Name = "H_Combat01",
        MinDoorCageRewards = 2,
    })

    lu.assertEquals(result, 2)
end

function TestBiomeControlLogic:testEphyraLogicReplacesHermesAndFiltersSubroomRewards()
    local harness = ResetBiomeControlHarness({
        controls = {
            ReplaceHermesInEphyra = "ApolloUpgrade",
            PackedBannedEphyraSubRoomRewards = bit32.lshift(1, 0),
            PackedBannedEphyraSubRoomRewardsHard = bit32.lshift(1, 2),
        },
        RewardStoreData = {
            HubRewards = {
                { Name = "HermesUpgrade", GameStateRequirements = { "remove me" } },
            },
            SubRoomRewards = {
                { Name = "MaxManaDropSmall" },
                { Name = "GiftDrop" },
            },
            SubRoomRewardsHard = {
                { Name = "StackUpgrade" },
                { Name = "Money" },
            },
        },
        CurrentRun = {},
        EncounterData = {
            BaseArtemisCombat = {},
        },
    })

    harness.applyPatchPlan()

    lu.assertEquals(RewardStoreData.HubRewards[1].Name, "ApolloUpgrade")
    lu.assertNil(RewardStoreData.HubRewards[1].GameStateRequirements)
    lu.assertEquals(RewardStoreData.SubRoomRewards, {
        { Name = "GiftDrop" },
    })
    lu.assertEquals(RewardStoreData.SubRoomRewardsHard, {
        { Name = "Money" },
    })
    lu.assertEquals(EncounterData.BaseArtemisCombat.RequireNotRoomReward, { "ApolloUpgrade" })
end

function TestBiomeControlLogic:testThessalyLogicForcesSelectedMiniboss()
    local harness = ResetBiomeControlHarness({
        controls = {
            ThessalyMiniBossMode = { mode = "charybdis", min = 3, max = 5 },
        },
        RoomData = {
            O_MiniBoss01 = {
                Name = "O_MiniBoss01",
                GameStateRequirements = {
                    { Path = { "CurrentRun", "BiomeDepthCache" }, Comparison = ">=", Value = 2 },
                    { Path = { "CurrentRun", "BiomeDepthCache" }, Comparison = "<=", Value = 4 },
                },
            },
            O_MiniBoss02 = {
                Name = "O_MiniBoss02",
                GameStateRequirements = {},
            },
        },
    })

    harness.applyPatchPlan()

    lu.assertTrue(RoomData.O_MiniBoss01.AlwaysForce)
    lu.assertEquals(RoomData.O_MiniBoss01.ForceAtBiomeDepthMin, 3)
    lu.assertEquals(RoomData.O_MiniBoss01.ForceAtBiomeDepthMax, 5)
    lu.assertEquals(RoomData.O_MiniBoss01.GameStateRequirements[1].Value, 3)
    lu.assertEquals(RoomData.O_MiniBoss01.GameStateRequirements[2].Value, 5)
    lu.assertEquals(RoomData.O_MiniBoss02.GameStateRequirements[1].Value, -1)
end

function TestBiomeControlLogic:testDreamRouteSetsNextRoomSetAndPool()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            DreamRoute = {
                Enabled = true,
                Biome1 = "G",
                Biome2 = "I",
                Biome3 = "N",
                Biome4 = "P",
            },
        },
        CurrentRun = {
            IsDreamRun = true,
            EnteredBiomes = 0,
            CurrentRoom = {},
        },
        GameState = {},
    })

    SelectNextDreamBiome(nil)

    lu.assertEquals(CurrentRun.CurrentRoom.NextRoomSet, { "G" })
    lu.assertEquals(CurrentRun.DreamBiomePool, { "I", "N", "P" })
    lu.assertEquals(GameState.LastDreamStartingBiome, "G")
end

function TestBiomeControlLogic:testDreamRouteFallbackPreservesSourceAndArgs()
    local observedSource = nil
    local observedArgs = nil
    local source = { Name = "DreamSource" }
    local args = {
        ForceHBiomeRequirements = {
            { Path = { "GameState", "RoomsEntered", "Dream_Intro" }, Comparison = "<=", Value = 1 },
        },
    }

    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            DreamRoute = {
                Enabled = false,
            },
        },
        CurrentRun = {
            IsDreamRun = true,
            EnteredBiomes = 0,
            CurrentRoom = {},
        },
        SelectNextDreamBiome = function(baseSource, baseArgs)
            observedSource = baseSource
            observedArgs = baseArgs
            return "base"
        end,
    })

    lu.assertEquals(SelectNextDreamBiome(source, args), "base")
    lu.assertIs(observedSource, source)
    lu.assertIs(observedArgs, args)
end

function TestBiomeControlLogic:testDreamRouteFallsBackForNaturalNextBiome()
    local baseCalled = false
    local source = { Name = "DreamSource" }
    local args = { SkipChooseReward = true }

    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
        },
        controls = {
            DreamRoute = {
                Enabled = true,
                Biome1 = "G",
                Biome2 = "H",
                Biome3 = "I",
                Biome4 = "O",
            },
        },
        CurrentRun = {
            IsDreamRun = true,
            EnteredBiomes = 1,
            BiomeVisitOrder = { "G" },
            CurrentRoom = {},
        },
        SelectNextDreamBiome = function(baseSource, baseArgs)
            baseCalled = baseSource == source and baseArgs == args
            CurrentRun.CurrentRoom.NextRoomSet = { "base" }
        end,
    })

    SelectNextDreamBiome(source, args)

    lu.assertTrue(baseCalled)
    lu.assertEquals(CurrentRun.CurrentRoom.NextRoomSet, { "base" })
end
