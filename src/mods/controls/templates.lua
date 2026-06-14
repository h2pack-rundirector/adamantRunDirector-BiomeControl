local shared = import("mods/controls/shared.lua")
local modeBase = import("mods/controls/Mode/base.lua", nil, {
    shared = shared,
})

return {
    Flag = import("mods/controls/Flag/Flag.lua", nil, {
        shared = shared,
    }),
    Choice = import("mods/controls/Choice/Choice.lua", nil, {
        shared = shared,
    }),
    GodChoice = import("mods/controls/GodChoice/GodChoice.lua", nil, {
        shared = shared,
    }),
    DreamRoute = import("mods/controls/DreamRoute/DreamRoute.lua", nil, {
        shared = shared,
    }),
    Mode = import("mods/controls/Mode/Mode.lua", nil, {
        base = modeBase,
    }),
    ModeWithRange = import("mods/controls/ModeWithRange/ModeWithRange.lua", nil, {
        base = modeBase,
        shared = shared,
    }),
    PackedSet = import("mods/controls/PackedSet/PackedSet.lua", nil, {
        shared = shared,
    }),
}
