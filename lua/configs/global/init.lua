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
                {"BufWinEnter", "NvimTree", "set colorcolumn=0 nocursorcolumn"}
            },
            yank = {
                {
                    "TextYankPost",
                    [[* silent! lua vim.highlight.on_yank({higroup='IncSearch', timeout=400})]]
                }
            },
            ft = {
                {"FileType", "dart", "set ts=2 sw=2"},
                {"FileType", "ruby", "set ts=2 sw=2"},
                {"FileType", "yaml", "set ts=2 sw=2"},
                {"FileType", "c", "set ts=2 sw=2"},
                {"FileType", "cpp", "set ts=2 sw=2"},
                {"FileType", "objc", "set ts=2 sw=2"},
                {"FileType", "objcpp", "set ts=2 sw=2"},
                {"FileType", "help", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "dashboard", "set nowrap"},
                {"FileType", "Trouble", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "Outline", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "VimspectorPrompt", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "git", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "packer", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "dapui_scopes", "set colorcolumn=0 nocursorcolumn"},
                {
                    "FileType",
                    "dapui_breakpoints",
                    "set colorcolumn=0 nocursorcolumn"
                },
                {"FileType", "dapui_stacks", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "dapui_watches", "set colorcolumn=0 nocursorcolumn"},
                {"FileType", "NeogitStatus", "set colorcolumn=0 nocursorcolumn"}
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
    vim.g.CtrlSpaceGlobCommand = "rg --files --follow --hidden -g '!{.git/*,node_modules/*,target/*,vendor/*}'"
    vim.g.CtrlSpaceIgnoredFiles = "\v(tmp|temp)[\\/]"
    vim.api.nvim_exec(
        [[
        let g:CtrlSpaceSymbols = { "CS": " ", "Sin": "", "All": "", "Vis": "★", "File": "", "Tabs": "ﱡ", "CTab": "ﱢ", "NTM": "⁺", "WLoad": "ﰬ", "WSave": "ﰵ", "Zoom": "", "SLeft": "", "SRight": "", "BM": "", "Help": "", "IV": "", "IA": "", "IM": " ", "Dots": "ﳁ"}
        ]],
        true
    )
end

return configs
