-- Plugin-system utilities: config execution, snapshot resolution, and commit lookup.
---@module "core.funcs.plugins"
local M = {}

-- Loads base and user config modules, deep-merges them (user wins on conflicts),
-- sorts the result so functions execute in a deterministic order, then calls each.
M.configs = function()
    local tbl = require("core.funcs.table")
    local base_configs = require("configs.base")
    local user_configs = require("configs.user")
    local unsort_configs = tbl.merge(base_configs, user_configs)
    local configs = tbl.sort(unsort_configs)
    for _, func in pairs(configs) do
        if type(func) == "function" then
            func()
        end
    end
end

-- Reads the active snapshot name from the cache and returns the path to its file.
-- Falls back to the "default" snapshot when no cache entry exists.
---@return string  Absolute path to the active snapshot file
M.get_snapshot = function()
    local fs = require("core.funcs.fs")
    local file_content = fs.read_file(_G.LVIM.global.cache_path .. "/.lvim_snapshot")
    if file_content ~= nil then
        if file_content["snapshot"] ~= nil then
            return file_content["snapshot"]
        end
    end
    return _G.LVIM.global.snapshot_path .. "/default"
end

-- Looks up the pinned commit hash for a plugin in a loaded snapshot table.
-- Returns nil when the snapshot is nil or the plugin has no entry.
---@param plugin           string           Plugin name as it appears in the snapshot
---@param plugins_snapshot LvimSnapshot|nil Decoded snapshot (from read_file)
---@return string|nil                       Commit hash, or nil if not pinned
M.get_commit = function(plugin, plugins_snapshot)
    if plugins_snapshot ~= nil then
        if plugins_snapshot[plugin] ~= nil and plugins_snapshot[plugin].commit ~= nil then
            return plugins_snapshot[plugin].commit
        end
    else
        return nil
    end
end

return M
