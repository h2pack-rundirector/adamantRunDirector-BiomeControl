local storageBuilder = {}

local function appendModeStorage(nodes, controller)
    local mode = controller.bindings and controller.bindings.mode
    if not mode then return end

    local valueLookup = {}
    for index, value in ipairs(mode.values or {}) do
        valueLookup[value] = index - 1
    end

    nodes[#nodes + 1] = {
        type = "int",
        alias = mode.alias,
        default = valueLookup[mode.default] or 0,
        min = 0,
        max = math.max(#(mode.values or {}) - 1, 0),
    }
end

local function appendRangeStorage(nodes, controller)
    local range = controller.bindings and controller.bindings.range
    if not range then return end

    nodes[#nodes + 1] = {
        type = "int",
        alias = range.minAlias,
        default = range.min,
        min = range.min,
        max = range.max,
    }
    nodes[#nodes + 1] = {
        type = "int",
        alias = range.maxAlias,
        default = range.max,
        min = range.min,
        max = range.max,
    }
end

local function appendValueStorage(nodes, controller)
    local value = controller.bindings and controller.bindings.value
    if not value then return end

    nodes[#nodes + 1] = {
        type = value.type or "string",
        alias = value.alias,
        default = value.default,
        maxLen = value.maxLen,
    }
end

local function appendPackedStorage(nodes, controller)
    local packed = controller.bindings and controller.bindings.packed
    if not packed then return end

    local bits = {}
    for _, option in ipairs(packed.options or {}) do
        bits[#bits + 1] = {
            alias = packed.alias .. "_" .. tostring(option.name or option.label or option.bit),
            label = option.label or tostring(option.name or option.bit),
            type = "bool",
            offset = option.bit,
            width = 1,
            default = false,
        }
    end

    nodes[#nodes + 1] = {
        type = "packedInt",
        alias = packed.alias,
        default = packed.default or 0,
        bits = bits,
    }
end

function storageBuilder.fromControllers(controllers)
    local nodes = {}
    for _, controller in ipairs(controllers or {}) do
        appendModeStorage(nodes, controller)
        appendRangeStorage(nodes, controller)
        appendValueStorage(nodes, controller)
        appendPackedStorage(nodes, controller)
    end
    return nodes
end

return storageBuilder
