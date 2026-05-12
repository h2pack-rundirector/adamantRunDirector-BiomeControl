return {
    key = "I",
    label = "Tartarus",
    region = "Underworld",
    ui = "mods/ui/biomes/i_tartarus.lua",
    rooms = {
        { id = "RatCatcher", type = "MiniBoss", roomKey = "I_MiniBoss01", label = "The Verminancer", min = 3, max = 7 },
        { id = "GoldElemental", type = "MiniBoss", roomKey = "I_MiniBoss02", label = "Goldwrath", min = 3, max = 7 },
    },
    npcs = {
        { id = "Nemesis", min = 4, max = 10 },
    },
}
