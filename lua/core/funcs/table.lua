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

return M
