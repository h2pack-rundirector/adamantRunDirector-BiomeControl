local storageNodes = {}

local STORAGE_TYPE_BY_FIELD_TYPE = {
    checkbox = "bool",
    dropdown = "string",
    int32 = "int",
    stepper = "int",
}

function storageNodes.appendStateField(target, field)
    local storageType = STORAGE_TYPE_BY_FIELD_TYPE[field.type] or field.type
    local default = field.default
    if default == nil then
        if storageType == "bool" then
            default = false
        elseif storageType == "string" then
            default = ""
        else
            default = field.min or 0
        end
    end
    target[#target + 1] = {
        type = storageType,
        alias = field.alias,
        default = default,
        min = field.min,
        max = field.max,
    }
end

function storageNodes.appendPackedReward(target, reward)
    local alias = reward.alias
    local bits = {}
    for _, option in ipairs(reward.options or {}) do
        bits[#bits + 1] = {
            alias = alias .. "_" .. tostring(option.name or option.label or option.bit),
            label = option.label or tostring(option.name or option.bit),
            type = "bool",
            offset = option.bit,
            width = 1,
            default = false,
        }
    end
    target[#target + 1] = {
        type = "packedInt",
        alias = alias,
        default = 0,
        bits = bits,
    }
end

function storageNodes.appendRangeField(target, field)
    target[#target + 1] = {
        type = "int",
        alias = field.rangeMinAlias,
        default = field.min,
        min = field.min,
        max = field.max,
    }
    target[#target + 1] = {
        type = "int",
        alias = field.rangeMaxAlias,
        default = field.max,
        min = field.min,
        max = field.max,
    }
end

function storageNodes.appendDepthRange(target, def, seen)
    if not seen[def.rangeMinAlias] then
        seen[def.rangeMinAlias] = true
        target[#target + 1] = {
            type = "int",
            alias = def.rangeMinAlias,
            default = def.minDefault,
            min = def.minDefault,
            max = def.maxDefault,
        }
    end
    if not seen[def.rangeMaxAlias] then
        seen[def.rangeMaxAlias] = true
        target[#target + 1] = {
            type = "int",
            alias = def.rangeMaxAlias,
            default = def.maxDefault,
            min = def.minDefault,
            max = def.maxDefault,
        }
    end
end

function storageNodes.gather(groups)
    local nodes = {}
    local orderedGroups = {
        groups.stateFields,
        groups.packedRewards,
        groups.rangeFields,
        groups.modeFields,
        groups.roomDepth,
        groups.npcDepth,
    }

    for _, group in ipairs(orderedGroups) do
        for _, node in ipairs(group or {}) do
            nodes[#nodes + 1] = node
        end
    end

    return nodes
end

return storageNodes
