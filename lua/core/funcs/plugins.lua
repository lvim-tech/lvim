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

-- The snapshots directory (version sets + the `active` marker).
---@return string
M.snapshot_dir = function()
    return _G.LVIM.global.lvim_path .. "/.snapshots"
end

-- Reads the active snapshot name from <snapshot_dir>/active; "default" when unset.
---@return string  Active snapshot name
M.get_snapshot = function()
    local f = io.open(M.snapshot_dir() .. "/active", "r")
    if f then
        local name = (f:read("*a") or ""):gsub("%s+", "")
        f:close()
        if name ~= "" then
            return name
        end
    end
    return "default"
end

-- Reads the active version snapshot, decoded ({ plugins = {…}, mason = {…} }), or {}.
---@return table
M.read_snapshot = function()
    local f = io.open(M.snapshot_dir() .. "/" .. M.get_snapshot(), "r")
    if not f then
        return {}
    end
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(vim.json.decode, content)
    return (ok and type(data) == "table") and data or {}
end

-- Looks up the pinned commit hash for a plugin in a loaded snapshot table.
-- Returns nil when the snapshot is nil or the plugin has no entry.
---@param plugin           string           Plugin name as it appears in the snapshot
---@param plugins_snapshot LvimSnapshot|nil Decoded snapshot (from read_file)
---@return string|nil                       Commit hash, or nil if not pinned
M.get_commit = function(plugin, plugins_snapshot)
    if type(plugins_snapshot) ~= "table" then
        return nil
    end
    -- A snapshot is `{ plugins = {…}, mason = {…} }`. (The flat lazy-lock shape it used to also
    -- accept is gone with the lockfile that had it — no backward compatibility.)
    -- A missing `plugins` key is NOT an error: `read_snapshot` returns `{}` when the snapshot file
    -- is absent, and every plugin then legitimately tracks HEAD. Indexing it unguarded threw
    -- `attempt to index a nil value` for the FIRST plugin the loader asked about, which aborted
    -- `lvim-pack.setup` and left the editor with no plugins at all.
    local plugins = plugins_snapshot.plugins
    if type(plugins) ~= "table" then
        return nil
    end
    local entry = plugins[plugin]
    if type(entry) ~= "table" then
        return nil
    end
    return entry.commit or entry.tag or entry.branch or nil
end

return M
