local funcs = require("core.funcs")
local data = require("lvim-control-center.persistence.data")
local utils = require("modules.base.configs.editor.control_center.utils")
local icons = require("configs.base.ui.icons")

return {
    name = "general",
    label = "General",
    icon = icons.common.vim2,
    settings = {
        {
            name = "relativenumber",
            label = "Show relative line numbers",
            type = "bool",
            default = false,
            get = function()
                return vim.opt.relativenumber.get()
            end,
            set = function(val, on_init)
                if on_init then
                    vim.opt.relativenumber = val
                else
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
        {
            name = "cursorline",
            label = "Show cursor line",
            type = "bool",
            default = true,
            get = function()
                return vim.opt.cursorline.get()
            end,
            set = function(val, on_init)
                if on_init then
                    vim.opt.cursorline = val
                else
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
        {
            name = "cursorcolumn",
            label = "Show cursor column",
            type = "bool",
            default = true,
            get = function()
                return vim.opt.cursorcolumn.get()
            end,
            set = function(val, on_init)
                if on_init then
                    vim.opt.cursorcolumn = val
                else
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                        local buf = vim.api.nvim_win_get_buf(win)
                        if not utils.is_excluded(buf, {}, { "neo-tree", "markdown", "Fyler" }) then
                            vim.wo[win].cursorcolumn = val
                        end
                    end
                    data.save("cursorcolumn", val)
                end
            end,
        },
        {
            name = "wrap",
            label = "Wrap lines",
            type = "bool",
            default = true,
            get = function()
                return vim.opt.wrap.get()
            end,
            set = function(val, on_init)
                if on_init then
                    vim.opt.wrap = val
                else
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
        {
            name = "colorcolumn",
            label = "Color column",
            type = "string",
            default = "80",
            get = function()
                return vim.opt.colorcolumn.get()
            end,
            set = function(val, on_init)
                if on_init then
                    vim.opt.colorcolumn = val
                else
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
        {
            name = "timeoutlen",
            label = "Timeout Length (ms)",
            type = "int",
            default = 500,
            get = function()
                return vim.o.timeoutlen
            end,
            set = function(val, on_init)
                vim.o.timeoutlen = val
                if not on_init then
                    data.save("timeoutlen", val)
                end
            end,
        },
        {
            name = "keyshelper",
            label = "Keys helper (need restart)",
            type = "bool",
            default = true,
            get = function()
                if _G.LVIM_KEYSHELPER ~= nil then
                    return _G.LVIM_KEYSHELPER
                else
                    return true
                end
            end,
            set = function(val, on_init)
                _G.LVIM_KEYSHELPER = val
                funcs.write_file(_G.global.lvim_path .. "/.configs/lvim/.keyshelper", _G.LVIM_KEYSHELPER)
                if not on_init then
                    data.save("keyshelper", val)
                end
            end,
        },
        {
            name = "keyshelperdelay",
            label = "Keys helper delay",
            type = "select",
            options = { 0, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 },
            default = 200,
            get = function()
                if _G.LVIM_SETTINGS and _G.LVIM_SETTINGS["keyshelperdelay"] ~= nil then
                    return _G.LVIM_SETTINGS["keyshelperdelay"]
                else
                    return true
                end
            end,
            set = function(val, on_init)
                _G.LVIM_SETTINGS["keyshelperdelay"] = val
                if not on_init then
                    vim.cmd("Lazy reload which-key.nvim")
                    data.save("keyshelperdelay", val)
                end
            end,
        },
    },
}
