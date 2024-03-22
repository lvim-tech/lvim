local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")
local icons = require("configs.base.ui.icons")

local M = {}

local telescope_menu = [[
                                       TELESCOPE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
File ]] .. icons.common.dot .. [[                                    _f_ │ _v_                                     ]] .. icons.common.dot .. [[ VIM
LSP  ]] .. icons.common.dot .. [[                                    _l_ │ _i_                                     ]] .. icons.common.dot .. [[ GIT
Treesitter                                _t_ │ _b_                              File browser

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.telescope_menu = Hydra({
    name = "TELESCOPE",
    hint = telescope_menu,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
        },
    },
    mode = { "n", "x", "v" },
    body = ";t",
    heads = {
        {
            "f",
            function()
                M.telescope_file:activate()
            end,
        },
        {
            "v",
            function()
                M.telescope_vim:activate()
            end,
        },
        {
            "l",
            function()
                M.telescope_lsp:activate()
            end,
        },
        {
            "i",
            function()
                M.telescope_git:activate()
            end,
        },
        {
            "t",
            keymap.cmd("Telescope treesitter"),
            { nowait = true, silent = true, desc = "Treesitter" },
        },
        {
            "b",
            keymap.cmd("Telescope file_browser"),
            { nowait = true, silent = true, desc = "File browser" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

local telescope_file_pickers = [[
                                     TELESCOPE FILE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Files                                 _<A-,>_ │ _<C-c><C-c>g_                       Git files
Grep string                     _<C-c><C-c>w_ │ _<A-.>_                             Live grep

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.telescope_file = Hydra({
    name = "TELESCOPE FILES",
    hint = telescope_file_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
        },
    },
    heads = {
        {
            "<A-,>",
            keymap.cmd("Telescope find_files"),
            { nowait = true, silent = true, desc = "Files" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("Telescope git_files"),
            { nowait = true, silent = true, desc = "Git files" },
        },
        {
            "<C-c><C-c>w",
            keymap.cmd("Telescope grep_string"),
            { nowait = true, silent = true, desc = "Grep string" },
        },
        {
            "<A-.>",
            keymap.cmd("Telescope live_grep"),
            { nowait = true, silent = true, desc = "Live grep" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local telescope_vim_pickers = [[
                                      TELESCOPE VIM

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Buffers                                _<A-b>_ │ _<C-c><C-c>o_                      Old files
Commands                         _<C-c><C-c>c_ │ _<C-c><C-c>t_                           Tags
Command history                  _<C-c><C-c>H_ │ _<C-c><C-c>s_                 Search history
Help tags                        _<C-c><C-c>T_ │ _<C-c><C-c>M_                      Man pages
Marks                            _<C-c><C-c>m_ │ _<C-c><C-c>O_                    Colorscheme
Quickfix                         _<C-c><C-c>q_ │ _<C-c><C-c>Q_               Quickfix history
Loc list                         _<C-c><C-c>L_ │ _<C-c><C-c>J_                      Jump list
Vim options                      _<C-c><C-c>v_ │ _<C-c><C-c>r_                      Registers
Autocommands                     _<C-c><C-c>A_ │ _<C-c><C-c>u_                  Spell suggest
Keymaps                          _<C-c><C-c>K_ │ _<C-c><C-c>f_                     File types
Highlights                       _<C-c><C-c>g_ │ _<C-c><C-c>R_                         Resume

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.telescope_vim = Hydra({
    name = "TELESCOPE VIM",
    hint = telescope_vim_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
        },
    },
    heads = {
        {
            "<A-b>",
            keymap.cmd("Telescope buffers"),
            { nowait = true, silent = true, desc = "Telescope buffers" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("Telescope oldfiles"),
            { nowait = true, silent = true, desc = "Telescope oldfiles" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("Telescope commands"),
            { nowait = true, silent = true, desc = "Telescope commands" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("Telescope tags"),
            { nowait = true, silent = true, desc = "Telescope tags" },
        },
        {
            "<C-c><C-c>H",
            keymap.cmd("Telescope command_history"),
            { nowait = true, silent = true, desc = "Telescope command history" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("Telescope search_history"),
            { nowait = true, silent = true, desc = "Telescope command search" },
        },
        {
            "<C-c><C-c>T",
            keymap.cmd("Telescope help_tags"),
            { nowait = true, silent = true, desc = "Telescope help tags" },
        },
        {
            "<C-c><C-c>M",
            keymap.cmd("Telescope man_pages"),
            { nowait = true, silent = true, desc = "Telescope man pages" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("Telescope marks"),
            { nowait = true, silent = true, desc = "Telescope marks" },
        },
        {
            "<C-c><C-c>O",
            keymap.cmd("Telescope colorscheme"),
            { nowait = true, silent = true, desc = "Telescope colorscheme" },
        },
        {
            "<C-c><C-c>q",
            keymap.cmd("Telescope quickfix"),
            { nowait = true, silent = true, desc = "Telescope quickfix" },
        },
        {
            "<C-c><C-c>Q",
            keymap.cmd("Telescope quickfixhistory"),
            { nowait = true, silent = true, desc = "Telescope quickfix history" },
        },
        {
            "<C-c><C-c>L",
            keymap.cmd("Telescope loclist"),
            { nowait = true, silent = true, desc = "Telescope loc list" },
        },
        {
            "<C-c><C-c>J",
            keymap.cmd("Telescope jumplist"),
            { nowait = true, silent = true, desc = "Telescope jump list" },
        },
        {
            "<C-c><C-c>v",
            keymap.cmd("Telescope vim_options"),
            { nowait = true, silent = true, desc = "Telescope vim options" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("Telescope registers"),
            { nowait = true, silent = true, desc = "Telescope registers" },
        },
        {
            "<C-c><C-c>A",
            keymap.cmd("Telescope autocommands"),
            { nowait = true, silent = true, desc = "Telescope autocommands" },
        },
        {
            "<C-c><C-c>u",
            keymap.cmd("Telescope spell_suggest"),
            { nowait = true, silent = true, desc = "Telescope spell suggest" },
        },
        {
            "<C-c><C-c>K",
            keymap.cmd("Telescope keymaps"),
            { nowait = true, silent = true, desc = "Telescope keymaps" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("Telescope filetypes"),
            { nowait = true, silent = true, desc = "Telescope file types" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("Telescope highlights"),
            { nowait = true, silent = true, desc = "Telescope highlights" },
        },
        {
            "<C-c><C-c>R",
            keymap.cmd("Telescope resume"),
            { nowait = true, silent = true, desc = "Telescope resume" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local telescope_lsp_pickers = [[
                                      TELESCOPE LSP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Definitions                      _<C-c><C-c>d_ │ _<C-c><C-c>t_               Type definitions
References                       _<C-c><C-c>r_ │ _<C-c><C-c>m_                Implementations
Document symbols                _<C-c><C-c>sd_ │ _<C-c><C-c>sw_             Workspace symbols
Dynamic workspace symbols       _<C-c><C-c>sy_ │ _<C-c><C-c>g_                    Diagnostics
Incoming calls                   _<C-c><C-c>I_ │ _<C-c><C-c>O_                 Outgoing calls

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.telescope_lsp = Hydra({
    name = "TELESCOPE LSP",
    hint = telescope_lsp_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
        },
    },
    heads = {
        {
            "<C-c><C-c>d",
            keymap.cmd("Telescope lsp_definitions"),
            { nowait = true, silent = true, desc = "Telescope lsp definitions" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("Telescope lsp_type_definitions"),
            { nowait = true, silent = true, desc = "Telescope lsp type definitions" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("Telescope lsp_references"),
            { nowait = true, silent = true, desc = "Telescope lsp references" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("Telescope lsp_implementations"),
            { nowait = true, silent = true, desc = "Telescope lsp implementations" },
        },
        {
            "<C-c><C-c>sd",
            keymap.cmd("Telescope lsp_document_symbols"),
            { nowait = true, silent = true, desc = "Telescope lsp document symbols" },
        },
        {
            "<C-c><C-c>sw",
            keymap.cmd("Telescope lsp_workspace_symbols"),
            { nowait = true, silent = true, desc = "Telescope lsp workspace symbols" },
        },
        {
            "<C-c><C-c>sy",
            keymap.cmd("Telescope lsp_dynamic_workspace_symbols"),
            { nowait = true, silent = true, desc = "Telescope lsp dynamic workspace symbols" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("Telescope diagnostics"),
            { nowait = true, silent = true, desc = "Telescope diagnostics" },
        },
        {
            "<C-c><C-c>I",
            keymap.cmd("Telescope lsp_incoming_calls"),
            { nowait = true, silent = true, desc = "Telescope lsp incoming calls" },
        },
        {
            "<C-c><C-c>O",
            keymap.cmd("Telescope lsp_outgoing_calls"),
            { nowait = true, silent = true, desc = "Telescope lsp outgoing calls" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local telescope_git_pickers = [[
                                     TELESCOPE GIT

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Git commits                     _<C-c><C-c>c_ │ _<C-c><C-c>b_                    Git bcommits
Git branches                    _<C-c><C-c>r_ │ _<C-c><C-c>s_                      Git status
Git stash                       _<C-c><C-c>t_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.telescope_git = Hydra({
    name = "TELESCOPE GIT",
    hint = telescope_git_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
        },
    },
    heads = {
        {
            "<C-c><C-c>c",
            keymap.cmd("Telescope git_commits"),
            { nowait = true, silent = true, desc = "FzfLua git commuts" },
        },
        {
            "<C-c><C-c>b",
            keymap.cmd("Telescope git_bcommits"),
            { nowait = true, silent = true, desc = "FzfLua git bcommits" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("Telescope git_branches"),
            { nowait = true, silent = true, desc = "Telescope git branches" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("Telescope git_status"),
            { nowait = true, silent = true, desc = "Telescope git status" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("Telescope git_stash"),
            { nowait = true, silent = true, desc = "Telescope git stash" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

return M
