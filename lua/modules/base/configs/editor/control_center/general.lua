-- General editor settings group for the LVIM Control Center.
-- Contains toggles and inputs for common editor options: relative line numbers,
-- cursor line/column, line wrap, color column, key timeout, and the
-- which-key helper (both its enabled state and its popup delay).
-- All settings are persisted via the lvim-control-center data store.

---@module "modules.base.configs.editor.control_center.general"
---@diagnostic disable: undefined-field

local funcs = require("core.funcs")
local data = require("lvim-control-center.persistence.data")
local utils = require("modules.base.configs.editor.control_center.utils")
local icons = require("configs.base.ui.icons")

---@type table  Control Center settings group descriptor for general editor options
return {
    name = "general",
    label = "General",
    icon = icons.common.vim2,
    settings = {
        -- -----------------------------------------------------------------
        -- Relative line numbers
        -- -----------------------------------------------------------------
        {
            name = "relativenumber",
            label = "Show relative line numbers",
            type = "bool",
            default = false,
            ---@return boolean  Current value of vim.opt.relativenumber
            get = function()
                return vim.opt.relativenumber:get()
            end,
            ---@param val     boolean  Whether to enable relative numbers
            ---@param on_init boolean  True during startup; apply globally via vim.opt instead of per-window
            set = function(val, on_init)
                if on_init then
                    -- During init, set the global option so every future window inherits it.
                    vim.opt.relativenumber = val
                else
                    -- After init, iterate all open windows and apply the option only to
                    -- non-excluded filetypes (neo-tree, Fyler file manager).
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if not utils.is_excluded(buf, {}, { "neo-tree", "Fyler" }) then
                            vim.wo[win].relativenumber = val
                        end
                    end
                    data.save("relativenumber", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- Cursor line highlight
        -- -----------------------------------------------------------------
        {
            name = "cursorline",
            label = "Show cursor line",
            type = "bool",
            default = true,
            ---@return boolean  Current value of vim.opt.cursorline
            get = function()
                return vim.opt.cursorline:get()
            end,
            ---@param val     boolean  Whether to highlight the cursor line
            ---@param on_init boolean  True during startup
            set = function(val, on_init)
                if on_init then
                    vim.opt.cursorline = val
                else
                    -- Skip neo-tree sidebar; it manages its own cursorline.
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if not utils.is_excluded(buf, {}, { "neo-tree" }) then
                            vim.wo[win].cursorline = val
                        end
                    end
                    data.save("cursorline", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- Cursor column highlight
        -- -----------------------------------------------------------------
        {
            name = "cursorcolumn",
            label = "Show cursor column",
            type = "bool",
            default = true,
            ---@return boolean  Current value of vim.opt.cursorcolumn
            get = function()
                return vim.opt.cursorcolumn:get()
            end,
            ---@param val     boolean  Whether to highlight the cursor column
            ---@param on_init boolean  True during startup
            set = function(val, on_init)
                if on_init then
                    vim.opt.cursorcolumn = val
                else
                    -- Exclude filetypes where a vertical line is distracting or
                    -- meaningless: neo-tree, markdown, Fyler, time-machine-list.
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if not utils.is_excluded(buf, {}, { "neo-tree", "markdown", "Fyler", "time-machine-list" }) then
                            vim.wo[win].cursorcolumn = val
                        end
                    end
                    data.save("cursorcolumn", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- Line wrap
        -- -----------------------------------------------------------------
        {
            name = "wrap",
            label = "Wrap lines",
            type = "bool",
            default = true,
            ---@return boolean  Current value of vim.opt.wrap
            get = function()
                return vim.opt.wrap:get()
            end,
            ---@param val     boolean  Whether to soft-wrap long lines
            ---@param on_init boolean  True during startup
            set = function(val, on_init)
                if on_init then
                    vim.opt.wrap = val
                else
                    -- Markdown files intentionally manage their own wrap setting.
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if not utils.is_excluded(buf, {}, { "markdown" }) then
                            vim.wo[win].wrap = val
                        end
                    end
                    data.save("wrap", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- Color column position
        -- -----------------------------------------------------------------
        {
            name = "colorcolumn",
            label = "Color column",
            type = "string",
            -- Default column width guideline: 80 characters
            default = "80",
            ---@return string  Comma-separated list of column positions (from vim.opt.colorcolumn)
            get = function()
                local val = vim.opt.colorcolumn:get()
                return type(val) == "table" and table.concat(val, ",") or tostring(val)
            end,
            ---@param val     string   New column position(s) as a comma-separated string
            ---@param on_init boolean  True during startup
            set = function(val, on_init)
                if on_init then
                    vim.opt.colorcolumn = val
                else
                    -- neo-tree and Fyler have fixed narrow widths; skip them.
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if not utils.is_excluded(buf, {}, { "neo-tree", "Fyler" }) then
                            vim.wo[win].colorcolumn = val
                        end
                    end
                    data.save("colorcolumn", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- Key sequence timeout
        -- -----------------------------------------------------------------
        {
            name = "timeoutlen",
            label = "Timeout Length (ms)",
            type = "int",
            -- 500 ms is Neovim's built-in default.
            default = 500,
            ---@return integer  Current value of vim.o.timeoutlen in milliseconds
            get = function()
                return vim.o.timeoutlen
            end,
            ---@param val     integer  New timeout in milliseconds
            ---@param on_init boolean  True during startup
            set = function(val, on_init)
                vim.o.timeoutlen = val
                if not on_init then
                    data.save("timeoutlen", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- which-key helper toggle
        -- -----------------------------------------------------------------
        {
            name = "keyshelper",
            label = "Keys helper (need restart)",
            type = "bool",
            default = true,
            ---@return boolean  Whether the which-key popup is enabled (falls back to true when unset)
            get = function()
                if _G.LVIM.keyshelper ~= nil then
                    return _G.LVIM.keyshelper
                else
                    return true
                end
            end,
            ---@param val     boolean  New enabled state for the which-key helper
            ---@param on_init boolean  True during startup; skip persistence (file write is always done)
            set = function(val, on_init)
                _G.LVIM.keyshelper = val
                -- Persist to a flat file so the setting survives before the data store is ready.
                funcs.write_file(_G.LVIM.global.lvim_path .. "/.configs/lvim/.keyshelper", _G.LVIM.keyshelper)
                if not on_init then
                    data.save("keyshelper", val)
                end
            end,
        },
        -- -----------------------------------------------------------------
        -- which-key popup delay
        -- -----------------------------------------------------------------
        {
            name = "keyshelperdelay",
            label = "Keys helper delay",
            type = "select",
            -- Delay options in milliseconds; 0 means show immediately.
            options = { 0, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 },
            default = 200,
            ---@return integer|boolean  Current popup delay in ms (falls back to true — intentional upstream default)
            get = function()
                if _G.LVIM.settings and _G.LVIM.settings["keyshelperdelay"] ~= nil then
                    return _G.LVIM.settings["keyshelperdelay"]
                else
                    return true
                end
            end,
            ---@param val     integer  New delay in milliseconds
            ---@param on_init boolean  True during startup; skip live-reload of which-key
            set = function(val, on_init)
                _G.LVIM.settings["keyshelperdelay"] = val
                if not on_init then
                    -- Hot-reload which-key so the new delay takes effect without a restart.
                    vim.cmd("Lazy reload which-key.nvim")
                    data.save("keyshelperdelay", val)
                end
            end,
        },
    },
}
