local funcs = require("core.funcs")
local lvim = require("configs.global.lvim")
local keymaps = require("configs.global.keymaps")

local configs = {}

configs["vim_global"] = function()
    lvim.global()
    lvim.set()
end

configs["events_global"] = function()
    vim.api.nvim_create_autocmd(
        "FileType",
        {
            pattern = {"dart", "ruby", "yaml", "c", "cpp", "objc", "objcpp"},
            command = "setlocal ts=2 sw=2"
        }
    )
    vim.api.nvim_create_autocmd(
        "FileType",
        {
            pattern = {
                "help",
                "Trouble",
                "Outline",
                "git",
                "dapui_scopes",
                "dapui_breakpoints",
                "dapui_stacks",
                "dapui_watches",
                "NeogitStatus"
            },
            command = "setlocal colorcolumn=0 nocursorcolumn"
        }
    )
    vim.api.nvim_create_autocmd(
        "FileType",
        {
            pattern = {"dashboard"},
            command = "setlocal nowrap"
        }
    )
    vim.api.nvim_create_autocmd(
        "FileType",
        {
            pattern = {"org"},
            command = "setlocal foldmethod=expr"
        }
    )
    vim.api.nvim_create_autocmd(
        "FileType",
        {
            pattern = {"org"},
            command = "setlocal foldexpr=nvim_treesitter#foldexpr()"
        }
    )
end

configs["languages_global"] = function()
    vim.api.nvim_create_autocmd(
        "BufWinEnter",
        {
            pattern = "*",
            command = 'lua require("languages.global").setup()'
        }
    )
end

configs["commands_global"] = function()
    vim.cmd('command! SetGlobalPath lua require("core.funcs").set_global_path()')
    vim.cmd('command! SetWindowPath lua require("core.funcs").set_window_path()')
end

configs["keymaps_global"] = function()
    funcs.keymaps("n", {noremap = false, silent = true}, keymaps.normal)
    funcs.keymaps("x", {noremap = false, silent = true}, keymaps.visual)
end

configs["indent_char_global"] = function()
    vim.g.indent_blankline_char = "▏"
    vim.g.indentLine_char = "▏"
end

configs["ctrlspace_pre_config_global"] = function()
    vim.g.ctrlspace_use_tablineend = 1
    vim.g.CtrlSpaceLoadLastWorkspaceOnStart = 1
    vim.g.CtrlSpaceSaveWorkspaceOnSwitch = 1
    vim.g.CtrlSpaceSaveWorkspaceOnExit = 1
    vim.g.CtrlSpaceUseTabline = 0
    vim.g.CtrlSpaceUseArrowsInTerm = 1
    vim.g.CtrlSpaceUseMouseAndArrowsInTerm = 1
    vim.g.CtrlSpaceGlobCommand = "rg --files --follow --hidden -g '!{.git/*,node_modules/*,target/*,vendor/*}'"
    vim.g.CtrlSpaceIgnoredFiles = "\v(tmp|temp)[\\/]"
    vim.g.CtrlSpaceSymbols = {
        CS = " ",
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
        Dots = "ﳁ"
    }
end

return configs
