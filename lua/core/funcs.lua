-- Public API aggregator for core.funcs.
-- Re-exports every function from the submodules so that all existing callers
-- using require("core.funcs").something continue to work without modification.
-- To use a specific submodule directly: require("core.funcs.color"), etc.
---@module "core.funcs"
local M = {}

local submodules = {
    "core.funcs.table",
    "core.funcs.fs",
    "core.funcs.color",
    "core.funcs.system",
    "core.funcs.ui",
    "core.funcs.editor",
    "core.funcs.plugins",
}

for _, name in ipairs(submodules) do
    for k, v in pairs(require(name)) do
        M[k] = v
    end
end

return M
