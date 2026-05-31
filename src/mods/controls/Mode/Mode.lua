local deps = ...

local base = deps.base

return {
    prepare = base.prepare,
    storage = base.storage,
    createRuntime = base.createRuntime,
    createUi = base.createUi,
    draw = base.draw,
}
