-- Public API aggregator for core.funcs.
-- Lazily resolves each function from its submodule on first access via an
-- __index metatable, caching the result, so that require("core.funcs") does not
-- eagerly load every submodule. On a name collision the earlier entry in
-- `submodules` wins (deterministic resolution order).
-- To use a specific submodule directly: require("core.funcs.fs"), etc.
---@module "core.funcs"

local submodules = {
    "core.funcs.table",
    "core.funcs.fs",
    "core.funcs.system",
    "core.funcs.ui",
    "core.funcs.editor",
    "core.funcs.plugins",
}

return setmetatable({}, {
    __index = function(t, key)
        for _, name in ipairs(submodules) do
            local value = require(name)[key]
            if value ~= nil then
                t[key] = value -- cache for subsequent lookups
                return value
            end
        end
        return nil
    end,
})
