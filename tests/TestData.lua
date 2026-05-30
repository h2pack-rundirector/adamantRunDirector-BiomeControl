local lu = require("luaunit")

TestBiomeControlData = {}

local function getStorageNode(storage, alias)
    for _, node in ipairs(storage) do
        if node.alias == alias then
            return node
        end
    end
end

function TestBiomeControlData:testCatalogKeepsBiomeAndNpcSettings()
    local data = dofile("src/mods/data.lua")
    local catalog = data.catalog

    local arachne = catalog.biomes.F.rooms.Arachne
    lu.assertEquals(arachne.setting.name, "StoryArachne")
    lu.assertEquals(arachne.setting.template, "ModeWithRange")
    lu.assertEquals(arachne.setting.range.min, 4)
    lu.assertEquals(arachne.setting.range.max, 8)

    local trial = catalog.biomes.F.rooms.Trial
    lu.assertEquals(trial.setting.name, "TrialErebus")
    lu.assertEquals(trial.setting.range.min, 6)
    lu.assertEquals(trial.setting.range.max, 10)

    local nemesis = catalog.npcs.Nemesis.lookup.I
    lu.assertEquals(nemesis.setting.name, "NPCNemesisTartarus")
    lu.assertEquals(nemesis.setting.template, "ModeWithRange")
end

function TestBiomeControlData:testControlsAreDeclaredBySemanticTemplate()
    local data = dofile("src/mods/data.lua")
    local controls = data.controls.build()

    lu.assertEquals(controls.PreventEchoScam.template, "Flag")
    lu.assertEquals(controls.ReplaceHermesInEphyra.template, "Choice")
    lu.assertEquals(controls.EphyraMiniBossMode.template, "Mode")
    lu.assertEquals(controls.ThessalyMiniBossMode.template, "ModeWithRange")
    lu.assertEquals(controls.PackedBannedEphyraSubRoomRewards.template, "PackedSet")
    lu.assertEquals(#controls.PackedBannedEphyraSubRoomRewards.options, 16)
end

function TestBiomeControlData:testStorageOnlyKeepsNonControlAliases()
    local data = dofile("src/mods/data.lua")
    local storage = data.storage.build()

    lu.assertEquals(getStorageNode(storage, "PriorityBiome1").type, "string")
    lu.assertEquals(getStorageNode(storage, "DreamRouteEnabled").type, "bool")
    lu.assertNil(getStorageNode(storage, "PreventEchoScam"))
    lu.assertNil(getStorageNode(storage, "StoryArachne"))
end

function TestBiomeControlData:testBaseAndBiomeControlsShareOneDeclarationSurface()
    local data = dofile("src/mods/data.lua")
    local controls = data.controls.build()

    lu.assertEquals(controls.OnlyAllowForcedEncounters.template, "Flag")
    lu.assertEquals(controls.IgnoreMaxDepth.template, "Flag")
    lu.assertEquals(controls.NPCSpacing.template, "Choice")
    lu.assertEquals(controls.StoryArachne.template, "ModeWithRange")
end
