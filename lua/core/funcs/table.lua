-- Table utilities that this config still uses.
-- (`sort`, `has_value`, `merge_unique`, `remove_duplicate`, `custom_sort` and `find_key_by_value`
-- lived here for the lazy.nvim-era modules and had no call site left — the statusline's
-- `remove_duplicate` is lvim-hud's own, not this one.)
---@module "core.funcs.table"
local M = {}

-- Deep-merges tbl2 into tbl1 in-place. Nested tables are merged recursively;
-- scalar values and mixed-type keys are overwritten by tbl2.
---@param tbl1 table  Destination table (mutated)
---@param tbl2 table  Source table
---@return table      tbl1 after merging
M.merge = function(tbl1, tbl2)
    if type(tbl1) == "table" and type(tbl2) == "table" then
        for k, v in pairs(tbl2) do
            if type(v) == "table" and type(tbl1[k] or false) == "table" then
                M.merge(tbl1[k], v)
            else
                tbl1[k] = v
            end
        end
    end
    return tbl1
end

-- Sorts bracket-key lines (e.g. `["foo"] = ...`) in the current buffer
-- alphabetically, placing all other lines after them. Useful for keeping
-- plugin module tables tidy. Bound to :SortLuaTable.
M.sort_lua_table = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local sorted_lines = {}
    local inner_lines = {}
    for _, line in ipairs(lines) do
        if line:match('%[".*"%]') then
            table.insert(sorted_lines, line)
        else
            table.insert(inner_lines, line)
        end
    end
    table.sort(sorted_lines)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, sorted_lines)
    vim.api.nvim_buf_set_lines(0, #sorted_lines, -1, false, inner_lines)
end

return M
