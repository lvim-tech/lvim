local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local telescope_menu = [[
                         TELESCOPE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
File                        _f_ │ _v_                        VIM
LSP                         _l_ │ _g_                        GIT
Treesitter                  _t_ │ _b_               File browser

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

M.telescope_menu = Hydra({
    name = "TELESCOPE",
    hint = telescope_menu,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = "<leader>t",
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
            "g",
            function()
                M.telescope_git:activate()
            end,
        },
        {
            "t",
            keymap.cmd("Telescope treesitter"),
            { silent = true, desc = "Treesitter" },
        },
        {
            "b",
            keymap.cmd("Telescope file_browser"),
            { silent = true, desc = "File browser" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})

local telescope_file_pickers = [[
                      TELESCOPE FILE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Files                       _f_ │ _g_                  Git files
Grep string                 _w_ │ _l_                  Live grep

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.telescope_file = Hydra({
    name = "TELESCOPE FILES",
    hint = telescope_file_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = "<leader>tf",
    heads = {
        {
            "f",
            keymap.cmd("Telescope find_files"),
            { silent = true, desc = "Files" },
        },
        {
            "g",
            keymap.cmd("Telescope git_files"),
            { silent = true, desc = "Git files" },
        },
        {
            "w",
            keymap.cmd("Telescope grep_string"),
            { silent = true, desc = "Grep string" },
        },
        {
            "l",
            keymap.cmd("Telescope live_grep"),
            { silent = true, desc = "Live grep" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<Esc>",
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
Command history             _h_ │ _s_             Search history
Help tags                   _H_ │ _M_                  Man pages
Marks                       _m_ │ _O_                Colorscheme
Quickfix                    _q_ │ _Q_           Quickfix history
Loc list                    _l_ │ _j_                  Jump list
Vim options                 _v_ │ _r_                  Registers
Autocommands                _a_ │ _u_              Spell suggest
Keymaps                     _k_ │ _f_                 File types
Highlights                  _g_ │ _R_                     Resume

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.telescope_vim = Hydra({
    name = "TELESCOPE VIM",
    hint = telescope_vim_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = "<leader>tv",
    heads = {
        {
            "b",
            keymap.cmd("Telescope buffers"),
            { silent = true, desc = "Telescope buffers" },
        },
        {
            "o",
            keymap.cmd("Telescope oldfiles"),
            { silent = true, desc = "Telescope oldfiles" },
        },
        {
            "c",
            keymap.cmd("Telescope commands"),
            { silent = true, desc = "Telescope commands" },
        },
        {
            "t",
            keymap.cmd("Telescope tags"),
            { silent = true, desc = "Telescope tags" },
        },
        {
            "h",
            keymap.cmd("Telescope command_history"),
            { silent = true, desc = "Telescope command history" },
        },
        {
            "s",
            keymap.cmd("Telescope search_history"),
            { silent = true, desc = "Telescope command search" },
        },
        {
            "H",
            keymap.cmd("Telescope help_tags"),
            { silent = true, desc = "Telescope help tags" },
        },
        {
            "M",
            keymap.cmd("Telescope man_pages"),
            { silent = true, desc = "Telescope man pages" },
        },
        {
            "m",
            keymap.cmd("Telescope marks"),
            { silent = true, desc = "Telescope marks" },
        },
        {
            "O",
            keymap.cmd("Telescope colorscheme"),
            { silent = true, desc = "Telescope colorscheme" },
        },
        {
            "q",
            keymap.cmd("Telescope quickfix"),
            { silent = true, desc = "Telescope quickfix" },
        },
        {
            "Q",
            keymap.cmd("Telescope quickfixhistory"),
            { silent = true, desc = "Telescope quickfix history" },
        },
        {
            "l",
            keymap.cmd("Telescope loclist"),
            { silent = true, desc = "Telescope loc list" },
        },
        {
            "j",
            keymap.cmd("Telescope jumplist"),
            { silent = true, desc = "Telescope jump list" },
        },
        {
            "v",
            keymap.cmd("Telescope vim_options"),
            { silent = true, desc = "Telescope vim options" },
        },
        {
            "r",
            keymap.cmd("Telescope registers"),
            { silent = true, desc = "Telescope registers" },
        },
        {
            "a",
            keymap.cmd("Telescope autocommands"),
            { silent = true, desc = "Telescope autocommands" },
        },
        {
            "u",
            keymap.cmd("Telescope spell_suggest"),
            { silent = true, desc = "Telescope spell suggest" },
        },
        {
            "k",
            keymap.cmd("Telescope keymaps"),
            { silent = true, desc = "Telescope keymaps" },
        },
        {
            "f",
            keymap.cmd("Telescope filetypes"),
            { silent = true, desc = "Telescope file types" },
        },
        {
            "g",
            keymap.cmd("Telescope highlights"),
            { silent = true, desc = "Telescope highlights" },
        },
        {
            "R",
            keymap.cmd("Telescope resume"),
            { silent = true, desc = "Telescope resume" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<Esc>",
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
Incoming calls              _i_ │ _o_             Outgoing calls

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.telescope_lsp = Hydra({
    name = "TELESCOPE LSP",
    hint = telescope_lsp_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = "<leader>tl",
    heads = {
        {
            "d",
            keymap.cmd("Telescope lsp_definitions"),
            { silent = true, desc = "Telescope lsp definitions" },
        },
        {
            "t",
            keymap.cmd("Telescope lsp_type_definitions"),
            { silent = true, desc = "Telescope lsp type definitions" },
        },
        {
            "r",
            keymap.cmd("Telescope lsp_references"),
            { silent = true, desc = "Telescope lsp references" },
        },
        {
            "m",
            keymap.cmd("Telescope lsp_implementations"),
            { silent = true, desc = "Telescope lsp implementations" },
        },
        {
            "sd",
            keymap.cmd("Telescope lsp_document_symbols"),
            { silent = true, desc = "Telescope lsp document symbols" },
        },
        {
            "sw",
            keymap.cmd("Telescope lsp_workspace_symbols"),
            { silent = true, desc = "Telescope lsp workspace symbols" },
        },
        {
            "sy",
            keymap.cmd("Telescope lsp_dynamic_workspace_symbols"),
            { silent = true, desc = "Telescope lsp dynamic workspace symbols" },
        },
        {
            "g",
            keymap.cmd("Telescope diagnostics"),
            { silent = true, desc = "Telescope diagnostics" },
        },
        {
            "i",
            keymap.cmd("Telescope lsp_incoming_calls"),
            { silent = true, desc = "Telescope lsp incoming calls" },
        },
        {
            "o",
            keymap.cmd("Telescope lsp_outgoing_calls"),
            { silent = true, desc = "Telescope lsp outgoing calls" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<Esc>",
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
               exit => _<Esc>_  │  back => _<BS>_
]]

M.telescope_git = Hydra({
    name = "TELESCOPE GIT",
    hint = telescope_git_pickers,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = "<leader>tg",
    heads = {
        {
            "c",
            keymap.cmd("Telescope git_commits"),
            { silent = true, desc = "FzfLua git commuts" },
        },
        {
            "b",
            keymap.cmd("Telescope git_bcommits"),
            { silent = true, desc = "FzfLua git bcommits" },
        },
        {
            "r",
            keymap.cmd("Telescope git_branches"),
            { silent = true, desc = "Telescope git branches" },
        },
        {
            "s",
            keymap.cmd("Telescope git_status"),
            { silent = true, desc = "Telescope git status" },
        },
        {
            "t",
            keymap.cmd("Telescope git_stash"),
            { silent = true, desc = "Telescope git stash" },
        },
        {
            "<BS>",
            function()
                M.telescope_menu:activate()
            end,
        },
        {
            "<Esc>",
            nil,
            { exit = true, desc = false },
        },
    },
})

return M
