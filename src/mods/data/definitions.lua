local definitions = {}

definitions.roomModeValues = { "default", "disabled", "forced" }
definitions.roomModeDisplayValues = {
    default = "Default",
    disabled = "Disabled",
    forced = "Forced",
}

definitions.dreamBiomeOptions = { "F", "G", "H", "I", "N", "O", "P", "Q" }
definitions.dreamNaturalNextBiome = {
    F = "G",
    G = "H",
    H = "I",
    N = "O",
    N_SubRooms = "O",
    O = "P",
    P = "Q",
}

definitions.priorityGods = {
    { label = "Aphrodite",  lootKey = "AphroditeUpgrade",  colorKey = "AphroditeVoice" },
    { label = "Apollo",     lootKey = "ApolloUpgrade",     colorKey = "ApolloVoice" },
    { label = "Ares",       lootKey = "AresUpgrade",       colorKey = "AresVoice" },
    { label = "Demeter",    lootKey = "DemeterUpgrade",    colorKey = "DemeterVoice" },
    { label = "Hephaestus", lootKey = "HephaestusUpgrade", colorKey = "HephaestusVoice" },
    { label = "Hera",       lootKey = "HeraUpgrade",       colorKey = "HeraDamage" },
    { label = "Hestia",     lootKey = "HestiaUpgrade",     colorKey = "HestiaVoice" },
    { label = "Poseidon",   lootKey = "PoseidonUpgrade",   colorKey = "PoseidonVoice" },
    { label = "Zeus",       lootKey = "ZeusUpgrade",       colorKey = "ZeusVoice" },
}

return definitions
