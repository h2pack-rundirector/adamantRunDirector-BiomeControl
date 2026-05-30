return {
    key = "G",
    label = "Oceanus",
    region = "Underworld",
    logic = "mods/logic/biomes/g_oceanus.lua",
    ui = "mods/ui/biomes/g_oceanus.lua",
    rooms = {
        { id = "Narcissus", type = "Story", min = 3, max = 6 },
        { id = "Trial", type = "Trial", useRegionInKey = true, min = 3, max = 7 },
        { id = "Fountain", type = "Fountain", useRegionInKey = true, min = 4, max = 6 },
        { id = "Shop", type = "Shop", useRegionInKey = true, min = 3, max = 6 },
        { id = "WaterUnit", type = "MiniBoss", roomKey = "G_MiniBoss01", label = "Deep Serpent", min = 4, max = 7 },
        { id = "Crawler", type = "MiniBoss", roomKey = "G_MiniBoss02", label = "King Vermin", min = 4, max = 7 },
        { id = "Jellyfish", type = "MiniBoss", roomKey = "G_MiniBoss03", label = "Hellifish", min = 4, max = 7 },
    },
    npcs = {
        { id = "Artemis", groupKey = "ArtemisUnderworld", min = 4, max = 10 },
        { id = "Nemesis", min = 4, max = 10 },
    },
}
