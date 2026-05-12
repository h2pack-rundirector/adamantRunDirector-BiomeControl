return {
    key = "F",
    label = "Erebus",
    region = "Underworld",
    logic = "mods/logic/biomes/f_erebus.lua",
    ui = "mods/ui/biomes/f_erebus.lua",
    rooms = {
        { id = "Arachne", type = "Story", min = 4, max = 8 },
        { id = "Trial", type = "Trial", useRegionInKey = true, min = 6, max = 10 },
        { id = "Fountain", type = "Fountain", useRegionInKey = true, min = 4, max = 8 },
        { id = "Shop", type = "Shop", useRegionInKey = true, min = 4, max = 6 },
        { id = "Treant", type = "MiniBoss", roomKey = "F_MiniBoss01", label = "Root-Stalker", min = 4, max = 6 },
        { id = "FogEmitter", type = "MiniBoss", roomKey = "F_MiniBoss02", label = "Shadow-Spiller", min = 4, max = 6 },
        { id = "Assassin", type = "MiniBoss", roomKey = "F_MiniBoss03", label = "Master-Slicer", min = 4, max = 6 },
    },
    npcs = {
        { id = "Artemis", groupKey = "ArtemisUnderworld", min = 4, max = 10 },
        { id = "Nemesis", min = 4, max = 10 },
    },
}
