-- Shared helpers for the LVIM Control Center groups.
-- Exports:
--   merge_lists(t1, t2)              concatenate two array tables into a new one.
--   is_excluded(buf, extra_bt, extra_ft)
--                                    true when a buffer should be skipped by UI
--                                    features, matching its buftype/filetype
--                                    against the base exclusion lists plus any
--                                    extra buftypes/filetypes passed in.

---@module "modules.base.configs.editor.control_center.utils"

local M = {}

local base_bt = {}
local base_ft = { "", "lvim-control-center", "snacks_dashboard" }

M.merge_lists = function(t1, t2)
    local res = {}
    for _, v in ipairs(t1 or {}) do
        res[#res + 1] = v
    end
    for _, v in ipairs(t2 or {}) do
        res[#res + 1] = v
    end
    return res
end

M.is_excluded = function(buf, extra_bt, extra_ft)
    local exclude_bt = M.merge_lists(base_bt, extra_bt)
    local exclude_ft = M.merge_lists(base_ft, extra_ft)
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    for _, ebt in ipairs(exclude_bt or {}) do
        if bt == ebt then
            return true
        end
    end
    for _, eft in ipairs(exclude_ft or {}) do
        if ft == eft then
            return true
        end
    end
    return false
end

return M
