return {
    key = "P",
    label = "Olympus",
    region = "Surface",
    ui = "mods/ui/biomes/p_olympus.lua",
    rooms = {
        { id = "Dionysus", type = "Story", min = 3, max = 7 },
        { id = "Fountain", type = "Fountain", useRegionInKey = true, min = 4, max = 7 },
        { id = "Shop", type = "Shop", useRegionInKey = true, min = 5, max = 7 },
        { id = "Talos", type = "MiniBoss", roomKey = "P_MiniBoss01", label = "Talos", min = 4, max = 7 },
        { id = "Dragon", type = "MiniBoss", roomKey = "P_MiniBoss02", label = "Mega-Dracon", min = 4, max = 7 },
    },
    npcs = {
        { id = "Heracles", min = 0, max = 10 },
        { id = "Athena", min = 4, max = 8 },
        { id = "Icarus", min = 3, max = 8 },
    },
}
