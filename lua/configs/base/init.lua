local global = require("core.global")
local funcs = require("core.funcs")
local options = require("configs.base.options")
local keymaps = require("configs.base.keymaps")
local group = vim.api.nvim_create_augroup("LvimIDE", {
    clear = true,
})

local configs = {}

configs["base_vim"] = function()
    options.global()
end

configs["base_colors"] = function()
    _G.LVIM_COLORS = {
        color_01 = "#A7C080",
        color_02 = "#F05F4E",
        color_03 = "#F2994B",
        color_04 = "#2AA198",
        color_05 = "#00839F",
        color_06 = "#83A598",
        bg = "#20262A",
        fg = "#4C5D67",
    }
end

configs["base_options"] = function()
    vim.g.indent_blankline_char = "▏"
    vim.g.indentLine_char = "▏"
    vim.g.gitblame_enabled = 0
    vim.g.gitblame_highlight_group = "CursorLine"
    pcall(function()
        vim.opt.splitkeep = "screen"
    end)
end

configs["base_events"] = function()
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {
            "c",
            "cpp",
            "dart",
            "haskell",
            "objc",
            "objcpp",
            "ruby",
        },
        command = "setlocal ts=2 sw=2",
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
        callback = function()
            local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo.buftype)
            local filetype = vim.tbl_contains({
                "calendar",
                "Outline",
                "git",
                "dapui_scopes",
                "dapui_breakpoints",
                "dapui_stacks",
                "dapui_watches",
                "NeogitStatus",
                "org",
                "octo",
                "toggleterm",
            }, vim.bo.filetype)
            if buftype or filetype then
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.cursorcolumn = false
                vim.opt_local.colorcolumn = "0"
            end
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
        callback = function()
            local filetype = vim.tbl_contains({
                "tex",
            }, vim.bo.filetype)
            if filetype then
                vim.opt_local.cursorcolumn = false
                vim.opt_local.colorcolumn = "0"
            end
        end,
        group = group,
    })
    vim.api.nvim_create_autocmd({
        "WinEnter",
        "WinLeave",
        "BufEnter",
        "BufLeave",
        "InsertEnter",
        "InsertLeave",
        "CursorMoved",
        "CursorMovedI",
    }, {
        callback = function()
            vim.schedule(function()
                vim.cmd("set cmdheight=0")
            end)
        end,
        group = group,
    })
end

configs["base_languages"] = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
            require("languages.base").setup()
        end,
        group = group,
    })
end

configs["base_commands"] = function()
    vim.api.nvim_create_user_command("SetGlobalPath", 'lua require("core.funcs").set_global_path()', {})
    vim.api.nvim_create_user_command("SetWindowPath", 'lua require("core.funcs").set_window_path()', {})
    vim.api.nvim_create_user_command("SudoWrite", 'lua require("core.funcs").sudo_write()', {})
    vim.api.nvim_create_user_command("Quit", 'lua require("core.funcs").quit()', {})
end

configs["base_keymaps"] = function()
    funcs.keymaps("n", { noremap = false, silent = true }, keymaps.normal)
    funcs.keymaps("x", { noremap = false, silent = true }, keymaps.visual)
end

configs["base_ctrlspace_pre_config"] = function()
    vim.g.ctrlspace_use_tablineend = 1
    vim.g.CtrlSpaceLoadLastWorkspaceOnStart = 0
    vim.g.CtrlSpaceSaveWorkspaceOnSwitch = 1
    vim.g.CtrlSpaceSaveWorkspaceOnExit = 1
    vim.g.CtrlSpaceUseTabline = 0
    vim.g.CtrlSpaceUseArrowsInTerm = 1
    vim.g.CtrlSpaceUseMouseAndArrowsInTerm = 1
    vim.g.CtrlSpaceGlobCommand = "rg --files --follow --hidden -g '!{.git/*,node_modules/*,target/*,vendor/*}'"
    vim.g.CtrlSpaceIgnoredFiles = "\v(tmp|temp)[\\/]"
    vim.g.CtrlSpaceSymbols = {
        CS = "",
        Sin = "",
        All = "",
        Vis = "★",
        File = "",
        Tabs = "ﱡ",
        CTab = "ﱢ",
        NTM = "⁺",
        WLoad = "ﰬ",
        WSave = "ﰵ",
        Zoom = "",
        SLeft = "",
        SRight = "",
        BM = "",
        Help = "",
        IV = "",
        IA = "",
        IM = " ",
        Dots = "ﳁ",
    }
end

configs["base_ask_packages"] = function()
    local lvim_packages_file = global.cache_path .. "/.lvim_packages"
    if funcs.file_exists(lvim_packages_file) then
        global.lvim_packages = true
    end
    vim.api.nvim_create_user_command("AskForPackagesFile", "lua require('core.funcs').delete_packages_file()", {})
end

return configs
