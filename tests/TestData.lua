local lu = require("luaunit")

TestBiomeControlData = {}

local function getStorageNode(storage, alias)
    for _, node in ipairs(storage) do
        if node.alias == alias then
            return node
        end
    end
end

local function getStorageIndex(storage, alias)
    for index, node in ipairs(storage) do
        if node.alias == alias then
            return index
        end
    end
end

local function getField(fields, alias)
    for _, field in ipairs(fields or {}) do
        if field.alias == alias then
            return field
        end
    end
end

local function getFieldIndex(fields, alias)
    for index, field in ipairs(fields or {}) do
        if field.alias == alias then
            return index
        end
    end
end

function TestBiomeControlData:testCatalogGeneratesStandardRoomAndNpcAliases()
    local data = dofile("src/mods/data.lua")
    local catalog = data.catalog

    local arachne = catalog.roomLookup.Arachne.F
    lu.assertEquals(arachne.modeKey, "ModeStoryArachne")
    lu.assertEquals(arachne.rangeMinAlias, "PackedStoryArachneMin")
    lu.assertEquals(arachne.rangeMaxAlias, "PackedStoryArachneMax")

    local trial = catalog.roomLookup.Trial.F
    lu.assertEquals(trial.modeKey, "ModeTrialErebus")
    lu.assertEquals(trial.rangeMinAlias, "PackedTrialErebusMin")
    lu.assertEquals(trial.rangeMaxAlias, "PackedTrialErebusMax")

    local nemesis = catalog.npcLookup.Nemesis.I
    lu.assertEquals(nemesis.modeKey, "ModeNPCNemesisTartarus")
    lu.assertEquals(nemesis.rangeMinAlias, "PackedNPCNemesisTartarusMin")
    lu.assertEquals(nemesis.rangeMaxAlias, "PackedNPCNemesisTartarusMax")
end

function TestBiomeControlData:testExtensionControlsAreAggregatedIntoCatalogSurface()
    local data = dofile("src/mods/data.lua")
    local controls = data.catalog

    lu.assertNotNil(getField(controls.stateFields, "PreventEchoScam"))
    lu.assertNotNil(getField(controls.stateFields, "ReplaceHermesInEphyra"))
    lu.assertNil(getField(controls.stateFields, "PackedBannedEphyraSubRoomRewards"))
    lu.assertNotNil(data.catalog.modeEntryLookup.EphyraMiniBossMode)
    lu.assertNotNil(data.catalog.modeEntryLookup.ThessalyMiniBossMode)
    lu.assertEquals(controls.biomeSpecials.H[1].alias, "PreventEchoScam")
    lu.assertEquals(controls.biomeRewards.N[2].alias, "PackedBannedEphyraSubRoomRewards")
    lu.assertEquals(controls.packedRewardFields.PackedBannedEphyraSubRoomRewards.alias, "PackedBannedEphyraSubRoomRewards")
    lu.assertEquals(controls.packedRewardFieldsOrdered[1].alias, "PackedBannedEphyraSubRoomRewards")
    lu.assertEquals(controls.packedRewardFieldsOrdered[2].alias, "PackedBannedEphyraSubRoomRewardsHard")
end

function TestBiomeControlData:testStorageKeepsExtensionAliasesStable()
    local data = dofile("src/mods/data.lua")
    local storage = data.storage.build()

    lu.assertEquals(getStorageNode(storage, "PreventEchoScam").type, "bool")
    lu.assertEquals(getStorageNode(storage, "ReplaceHermesInEphyra").type, "string")
    lu.assertEquals(getStorageNode(storage, "ThessalyMiniBossMode").type, "int")
    lu.assertEquals(getStorageNode(storage, "PackedForcedThessalyMiniBossMin").type, "int")

    local packed = getStorageNode(storage, "PackedBannedEphyraSubRoomRewards")
    lu.assertEquals(packed.type, "packedInt")
    lu.assertEquals(#packed.bits, 16)
end

function TestBiomeControlData:testGeneratedStorageKeepsBiomeOrderForExtensionFields()
    local data = dofile("src/mods/data.lua")
    local catalog = data.catalog
    local storage = data.storage.build()

    lu.assertTrue(
        getStorageIndex(storage, "PackedBannedEphyraSubRoomRewards")
            < getStorageIndex(storage, "PackedBannedEphyraSubRoomRewardsHard")
    )

    local storyIndex = getFieldIndex(catalog.modeStorageFields, "ModeStoryArachne")
    local ephyraMinibossIndex = getFieldIndex(catalog.modeStorageFields, "EphyraMiniBossMode")
    local thessalyMinibossIndex = getFieldIndex(catalog.modeStorageFields, "ThessalyMiniBossMode")
    lu.assertNotNil(storyIndex)
    lu.assertNotNil(ephyraMinibossIndex)
    lu.assertNotNil(thessalyMinibossIndex)
    lu.assertTrue(storyIndex < ephyraMinibossIndex)
    lu.assertTrue(ephyraMinibossIndex < thessalyMinibossIndex)
end
