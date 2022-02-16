local funcs = require("core.funcs")
local lvim = require("configs.global.lvim")
local keymaps = require("configs.global.keymaps")

local configs = {}

configs["vim_global"] = function()
    lvim.global()
    lvim.set()
end

configs["events_global"] = function()
    funcs.augroups(
        {
            bufs = {
                {
                    "BufWinEnter",
                    "*",
                    "setlocal formatoptions-=c formatoptions-=r formatoptions-=o "
                },
                {
                    "BufRead",
                    "*",
                    "setlocal formatoptions-=c formatoptions-=r formatoptions-=o "
                },
                {
                    "BufNewFile",
                    "*",
                    "setlocal formatoptions-=c formatoptions-=r formatoptions-=o "
                },
                {"BufNewFile,BufRead", "*.ex", "set filetype=elixir"},
                {"BufNewFile,BufRead", "*.exs", "set filetype=elixir"},
                {"BufNewFile,BufRead", "*.graphql", "set filetype=graphql"},
                {"BufWinEnter", "NvimTree", "setlocal colorcolumn=0 nocursorcolumn"}
            },
            yank = {
                {
                    "TextYankPost",
                    [[* silent! lua vim.highlight.on_yank({higroup='IncSearch', timeout=400})]]
                }
            },
            ft = {
                {"FileType", "dart", "setlocal ts=2 sw=2"},
                {"FileType", "ruby", "setlocal ts=2 sw=2"},
                {"FileType", "yaml", "setlocal ts=2 sw=2"},
                {"FileType", "c", "setlocal ts=2 sw=2"},
                {"FileType", "cpp", "setlocal ts=2 sw=2"},
                {"FileType", "objc", "setlocal ts=2 sw=2"},
                {"FileType", "objcpp", "setlocal ts=2 sw=2"},
                {"FileType", "help", "setlocal colorcolumn=0 nocursorcolumn"},
                {"FileType", "dashboard", "setlocal nowrap"},
                {"FileType", "Trouble", "setlocal colorcolumn=0 nocursorcolumn"},
                {
                    "FileType",
                    "Outline",
                    "setlocal colorcolumn=0 nocursorcolumn"
                },
                {"FileType", "git", "setlocal colorcolumn=0 nocursorcolumn"},
                {
                    "FileType",
                    "packer",
                    "setlocal colorcolumn=0 nocursorcolumn"
                },
                {"FileType", "dapui_scopes", "setlocal colorcolumn=0 nocursorcolumn"},
                {
                    "FileType",
                    "dapui_breakpoints",
                    "set colorcolumn=0 nocursorcolumn"
                },
                {"FileType", "dapui_stacks", "setlocal colorcolumn=0 nocursorcolumn"},
                {"FileType", "dapui_watches", "setlocal colorcolumn=0 nocursorcolumn"},
                {"FileType", "NeogitStatus", "setlocal colorcolumn=0 nocursorcolumn"}
            }
        }
    )
end

configs["languages_global"] = function()
    funcs.augroups(
        {
            languages_setup = {
                {"BufWinEnter", "*", 'lua require("languages.global").setup()'}
            }
        }
    )
end

configs["commands_global"] = function()
    vim.cmd('command! SetGlobalPath lua require("core.funcs").set_global_path()')
    vim.cmd('command! SetWindowPath lua require("core.funcs").set_window_path()')
    vim.cmd('command! TelescopeBrowser lua require("core.funcs").load_telescope_browser()')
    vim.cmd('command! TelescopeBookmarks lua require("core.funcs").load_telescope_bookmarks()')
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
