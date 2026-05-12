return {
    key = "H",
    label = "Fields",
    region = "Underworld",
    logic = "mods/logic/biomes/h_fields.lua",
    ui = "mods/ui/biomes/h_fields.lua",
    rooms = {
        { id = "Vampire", type = "MiniBoss", roomKey = "H_MiniBoss01", label = "Phantom", min = 2, max = 4 },
        { id = "Lamia", type = "MiniBoss", roomKey = "H_MiniBoss02", label = "Queen Lamia", min = 2, max = 4 },
    },
    npcs = {
        { id = "Nemesis", min = 4, max = 10 },
    },
    controls = {
        stateFields = {
            { type = "checkbox", alias = "PreventEchoScam", label = "Prevent Echo Scam" },
            { type = "checkbox", alias = "ForceTwoRewardFieldsOpeners", label = "Force 2 Rewards In First Two Rooms" },
        },
        specials = {
            {
                kind = "checkbox",
                alias = "PreventEchoScam",
                label = "Prevent Echo Scam",
                helpText = "(Prevent miniboss from spawning in same depth as Echo, which can prevent it from spawning at all)",
            },
            {
                kind = "checkbox",
                alias = "ForceTwoRewardFieldsOpeners",
                label = "Force 2 Rewards In First Two Rooms",
                helpText = "(Force normal H combat encounters to offer exactly 2 rewards at biome depth 1 and 2; " ..
                    "vanilla 3-reward promotion resumes after depth 2)",
            },
        },
    },
}
