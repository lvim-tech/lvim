-- Plugin-system utilities: config execution, snapshot resolution, and commit lookup.
---@module "core.funcs.plugins"
local M = {}

-- Loads base and user config modules, deep-merges them (user wins on conflicts),
-- then calls each config function in deterministic (alphabetical key) order.
-- The base table is deep-copied before merging so the cached require() result
-- is never mutated.
M.configs = function()
    local tbl = require("core.funcs.table")
    local base_configs = require("configs.base")
    local user_configs = require("configs.user")
    local configs = tbl.merge(vim.deepcopy(base_configs), user_configs)
    local keys = vim.tbl_keys(configs)
    table.sort(keys)
    for _, key in ipairs(keys) do
        if type(configs[key]) == "function" then
            configs[key]()
        end
    end
end

-- Reads the active snapshot name from the cache; returns "default" when unset.
---@return string  Active snapshot name
M.get_snapshot = function()
    local fs = require("core.funcs.fs")
    local file_content = fs.read_file(_G.LVIM.global.cache_path .. "/.lvim_snapshot")
    if type(file_content) == "table" and file_content.snapshot ~= nil then
        return file_content.snapshot
    end
    return "default"
end

-- Looks up the pinned commit hash for a plugin in a loaded snapshot table.
-- Returns nil when the snapshot is nil or the plugin has no entry.
---@param plugin           string           Plugin name as it appears in the snapshot
---@param plugins_snapshot LvimSnapshot|nil Decoded snapshot (from read_file)
---@return string|nil                       Commit hash, or nil if not pinned
M.get_commit = function(plugin, plugins_snapshot)
    if plugins_snapshot ~= nil and plugins_snapshot[plugin] ~= nil and plugins_snapshot[plugin].commit ~= nil then
        return plugins_snapshot[plugin].commit
    end
    return nil
end

return M
