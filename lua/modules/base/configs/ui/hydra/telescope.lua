local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local telescope_menu = [[
                         TELESCOPE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
File                        _f_ │ _v_                        VIM
LSP                         _d_ │ _g_                        GIT
Treesitter                  _t_ │ _b_               File browser

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<C-q>_
]]

M.telescope_menu = Hydra({
    name = "TELESCOPE",
    hint = telescope_menu,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            border = "single",
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
            "d",
            function()
                M.telescope_lsp:activate()
            end,
        },
        {
            "g",
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

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Files                       _f_ │ _g_                  Git files
Grep string                 _w_ │ _L_                  Live grep

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<C-q>_  │  back => _<BS>_
]]

M.telescope_file = Hydra({
    name = "TELESCOPE FILES",
    hint = telescope_file_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            border = "single",
        },
    },
    heads = {
        {
            "f",
            keymap.cmd("Telescope find_files"),
            { nowait = true, silent = true, desc = "Files" },
        },
        {
            "g",
            keymap.cmd("Telescope git_files"),
            { nowait = true, silent = true, desc = "Git files" },
        },
        {
            "w",
            keymap.cmd("Telescope grep_string"),
            { nowait = true, silent = true, desc = "Grep string" },
        },
        {
            "L",
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

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Buffers                     _b_ │ _o_                  Old files
Commands                    _c_ │ _t_                       Tags
Command history             _H_ │ _s_             Search history
Help tags                   _T_ │ _M_                  Man pages
Marks                       _m_ │ _O_                Colorscheme
Quickfix                    _q_ │ _Q_           Quickfix history
Loc list                    _L_ │ _J_                  Jump list
Vim options                 _v_ │ _r_                  Registers
Autocommands                _A_ │ _u_              Spell suggest
Keymaps                     _K_ │ _f_                 File types
Highlights                  _g_ │ _R_                     Resume

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<C-q>_  │  back => _<BS>_
]]

M.telescope_vim = Hydra({
    name = "TELESCOPE VIM",
    hint = telescope_vim_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            border = "single",
        },
    },
    heads = {
        {
            "b",
            keymap.cmd("Telescope buffers"),
            { nowait = true, silent = true, desc = "Telescope buffers" },
        },
        {
            "o",
            keymap.cmd("Telescope oldfiles"),
            { nowait = true, silent = true, desc = "Telescope oldfiles" },
        },
        {
            "c",
            keymap.cmd("Telescope commands"),
            { nowait = true, silent = true, desc = "Telescope commands" },
        },
        {
            "t",
            keymap.cmd("Telescope tags"),
            { nowait = true, silent = true, desc = "Telescope tags" },
        },
        {
            "H",
            keymap.cmd("Telescope command_history"),
            { nowait = true, silent = true, desc = "Telescope command history" },
        },
        {
            "s",
            keymap.cmd("Telescope search_history"),
            { nowait = true, silent = true, desc = "Telescope command search" },
        },
        {
            "T",
            keymap.cmd("Telescope help_tags"),
            { nowait = true, silent = true, desc = "Telescope help tags" },
        },
        {
            "M",
            keymap.cmd("Telescope man_pages"),
            { nowait = true, silent = true, desc = "Telescope man pages" },
        },
        {
            "m",
            keymap.cmd("Telescope marks"),
            { nowait = true, silent = true, desc = "Telescope marks" },
        },
        {
            "O",
            keymap.cmd("Telescope colorscheme"),
            { nowait = true, silent = true, desc = "Telescope colorscheme" },
        },
        {
            "q",
            keymap.cmd("Telescope quickfix"),
            { nowait = true, silent = true, desc = "Telescope quickfix" },
        },
        {
            "Q",
            keymap.cmd("Telescope quickfixhistory"),
            { nowait = true, silent = true, desc = "Telescope quickfix history" },
        },
        {
            "L",
            keymap.cmd("Telescope loclist"),
            { nowait = true, silent = true, desc = "Telescope loc list" },
        },
        {
            "J",
            keymap.cmd("Telescope jumplist"),
            { nowait = true, silent = true, desc = "Telescope jump list" },
        },
        {
            "v",
            keymap.cmd("Telescope vim_options"),
            { nowait = true, silent = true, desc = "Telescope vim options" },
        },
        {
            "r",
            keymap.cmd("Telescope registers"),
            { nowait = true, silent = true, desc = "Telescope registers" },
        },
        {
            "A",
            keymap.cmd("Telescope autocommands"),
            { nowait = true, silent = true, desc = "Telescope autocommands" },
        },
        {
            "u",
            keymap.cmd("Telescope spell_suggest"),
            { nowait = true, silent = true, desc = "Telescope spell suggest" },
        },
        {
            "K",
            keymap.cmd("Telescope keymaps"),
            { nowait = true, silent = true, desc = "Telescope keymaps" },
        },
        {
            "f",
            keymap.cmd("Telescope filetypes"),
            { nowait = true, silent = true, desc = "Telescope file types" },
        },
        {
            "g",
            keymap.cmd("Telescope highlights"),
            { nowait = true, silent = true, desc = "Telescope highlights" },
        },
        {
            "R",
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

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Definitions                 _d_ │ _t_           Type definitions
References                  _r_ │ _m_            Implementations
Document symbols           _sd_ │ _sw_         Workspace symbols
Dynamic workspace symbols  _sy_ │ _g_                Diagnostics
Incoming calls              _I_ │ _O_             Outgoing calls

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<C-q>_  │  back => _<BS>_
]]

M.telescope_lsp = Hydra({
    name = "TELESCOPE LSP",
    hint = telescope_lsp_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            border = "single",
        },
    },
    heads = {
        {
            "d",
            keymap.cmd("Telescope lsp_definitions"),
            { nowait = true, silent = true, desc = "Telescope lsp definitions" },
        },
        {
            "t",
            keymap.cmd("Telescope lsp_type_definitions"),
            { nowait = true, silent = true, desc = "Telescope lsp type definitions" },
        },
        {
            "r",
            keymap.cmd("Telescope lsp_references"),
            { nowait = true, silent = true, desc = "Telescope lsp references" },
        },
        {
            "m",
            keymap.cmd("Telescope lsp_implementations"),
            { nowait = true, silent = true, desc = "Telescope lsp implementations" },
        },
        {
            "sd",
            keymap.cmd("Telescope lsp_document_symbols"),
            { nowait = true, silent = true, desc = "Telescope lsp document symbols" },
        },
        {
            "sw",
            keymap.cmd("Telescope lsp_workspace_symbols"),
            { nowait = true, silent = true, desc = "Telescope lsp workspace symbols" },
        },
        {
            "sy",
            keymap.cmd("Telescope lsp_dynamic_workspace_symbols"),
            { nowait = true, silent = true, desc = "Telescope lsp dynamic workspace symbols" },
        },
        {
            "g",
            keymap.cmd("Telescope diagnostics"),
            { nowait = true, silent = true, desc = "Telescope diagnostics" },
        },
        {
            "I",
            keymap.cmd("Telescope lsp_incoming_calls"),
            { nowait = true, silent = true, desc = "Telescope lsp incoming calls" },
        },
        {
            "O",
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

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Git commits                 _c_ │ _b_               Git bcommits
Git branches                _r_ │ _s_                 Git status
Git stash                   _t_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<C-q>_  │  back => _<BS>_
]]

M.telescope_git = Hydra({
    name = "TELESCOPE GIT",
    hint = telescope_git_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            border = "single",
        },
    },
    heads = {
        {
            "c",
            keymap.cmd("Telescope git_commits"),
            { nowait = true, silent = true, desc = "FzfLua git commuts" },
        },
        {
            "b",
            keymap.cmd("Telescope git_bcommits"),
            { nowait = true, silent = true, desc = "FzfLua git bcommits" },
        },
        {
            "r",
            keymap.cmd("Telescope git_branches"),
            { nowait = true, silent = true, desc = "Telescope git branches" },
        },
        {
            "s",
            keymap.cmd("Telescope git_status"),
            { nowait = true, silent = true, desc = "Telescope git status" },
        },
        {
            "t",
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
