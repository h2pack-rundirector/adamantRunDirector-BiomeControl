local helpers = import("mods/data/catalog/helpers.lua")
local modeEntries = import("mods/data/catalog/mode_entries.lua")
local storageNodes = import("mods/data/catalog/storage_nodes.lua")
local catalogDeps = {
    helpers = helpers,
    modeEntries = modeEntries,
    storageNodes = storageNodes,
}
local roomControls = import("mods/data/catalog/room_controls.lua", nil, catalogDeps)
local npcControls = import("mods/data/catalog/npc_controls.lua", nil, catalogDeps)
local extensionControls = import("mods/data/catalog/extension_controls.lua", nil, catalogDeps)

local catalog = {}

local function createEmptyModel(biomeRegistry, biomes)
    return {
        biomes = biomes,
        biomeLookup = biomeRegistry.lookup or {},
        biomeTabs = {},
        biomeMap = {},
        roomDefinitions = {},
        roomLookup = {},
        biomeDefinitions = {},
        npcDefinitions = {},
        npcLookup = {},
        npcGroups = { orderedIds = {} },
        modeEntryLookup = {},
        modeStorageFields = {},
        stateFields = {},
        rangeFields = {},
        biomeRooms = {},
        biomeRewards = {},
        biomeSpecials = {},
        packedRewardFields = {},
        packedRewardFieldsOrdered = {},
        rangeFieldLookup = {},
        storageGroups = {
            stateFields = {},
            packedRewards = {},
            rangeFields = {},
            modeFields = {},
            roomDepth = {},
            npcDepth = {},
        },
        storageNodes = {},
    }
end

function catalog.create(args)
    local biomeRegistry = args.biomes or {}
    local biomes = biomeRegistry.ordered or biomeRegistry
    local roomSpecs = roomControls.collectSpecs(biomes)
    local npcSpecs = npcControls.collectSpecs(biomes)
    local model = createEmptyModel(biomeRegistry, biomes)

    for _, biome in ipairs(biomes) do
        extensionControls.prepareBiome(model, biome)
    end

    extensionControls.preparePackedRewards(model, biomes)
    extensionControls.prepareStateFields(model)
    extensionControls.prepareRangeFields(model)

    roomControls.define(model, args.defaults, roomSpecs)
    npcControls.define(model, args.defaults, npcSpecs)
    extensionControls.prepareModeFields(model, args.defaults, biomes)

    roomControls.buildLookups(model)
    npcControls.buildLookups(model)
    modeEntries.attachAccessors(model)
    model.storageNodes = storageNodes.gather(model.storageGroups)
    model.storageGroups = nil

    return model
end

return catalog
