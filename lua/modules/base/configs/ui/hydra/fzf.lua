local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local fzf_menu = [[
                             FZF

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Navigation                  _n_ │ _s_                     Search
Tags                        _t_ │ _g_                        GIT
LSP                         _d_ │ _D_                        DAP
Misc                        _m_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

M.fzf_menu = Hydra({
    name = "FZF",
    hint = fzf_menu,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";z",
    heads = {
        {
            "n",
            function()
                M.fzf_buffers_and_files:activate()
            end,
        },
        {
            "s",
            function()
                M.fzf_search:activate()
            end,
        },
        {
            "t",
            function()
                M.fzf_tags:activate()
            end,
        },
        {
            "g",
            function()
                M.fzf_git:activate()
            end,
        },
        {
            "d",
            function()
                M.fzf_lsp:activate()
            end,
        },
        {
            "D",
            function()
                M.fzf_dap:activate()
            end,
        },
        {
            "m",
            function()
                M.fzf_misc:activate()
            end,
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})

local fzf_buffers_and_files = [[
                       FZF NAVIGATION

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Buffers                     _b_ │ _q_                   Quickfix
Files                       _f_ │ _Q_             Quickfix stack
Lines                       _s_ │ _c_                    Loclist
Blines                      _S_ │ _C_              Loclist stack
Oldfiles                    _o_ │ _t_                       Tabs

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.fzf_buffers_and_files = Hydra({
    name = "FZF BUFFERS AND FILES",
    hint = fzf_buffers_and_files,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    -- mode = { "n", "x", "v" },
    -- body = ";zb",
    heads = {
        {
            "b",
            keymap.cmd("FzfLua buffers"),
            { silent = true, desc = "FzfLua buffers" },
        },
        {
            "f",
            keymap.cmd("FzfLua files"),
            { silent = true, desc = "FzfLua files" },
        },
        {
            "s",
            keymap.cmd("FzfLua lines"),
            { silent = true, desc = "FzfLua lines" },
        },
        {
            "S",
            keymap.cmd("FzfLua blines"),
            { silent = true, desc = "FzfLua blines" },
        },
        {
            "o",
            keymap.cmd("FzfLua oldfiles"),
            { silent = true, desc = "FzfLua oldfiles" },
        },
        {
            "q",
            keymap.cmd("FzfLua quickfix"),
            { silent = true, desc = "FzfLua quickfix" },
        },
        {
            "Q",
            keymap.cmd("FzfLua quickfix_stack"),
            { silent = true, desc = "FzfLua quickfix stack" },
        },
        {
            "c",
            keymap.cmd("FzfLua loclist"),
            { silent = true, desc = "FzfLua loclist" },
        },
        {
            "C",
            keymap.cmd("FzfLua loclist_stack"),
            { silent = true, desc = "FzfLua loclist stack" },
        },
        {
            "t",
            keymap.cmd("FzfLua tabs"),
            { silent = true, desc = "FzfLua tabs" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<Esc>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_search = [[
                         FZF SEARCH

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Grep                        _g_ │ _G_                  Live grep
Grep last                   _L_ │ _r_           Live grep resume
Grep cword                  _w_ │ _o_             Live grep glob
Grep cWORD                  _W_ │ _n_           Live grep native
Grep visual                 _v_ │ _b_                Grep curbuf
Grep project                _p_ │ _B_               Lgrep curbuf

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.fzf_search = Hydra({
    name = "FZF SEARCH",
    hint = fzf_search,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    -- mode = { "n", "x", "v" },
    -- body = ";zs",
    heads = {
        {
            "g",
            keymap.cmd("FzfLua grep"),
            { silent = true, desc = "FzfLua grep" },
        },
        {
            "L",
            keymap.cmd("FzfLua grep_last"),
            { silent = true, desc = "FzfLua grep last" },
        },
        {
            "w",
            keymap.cmd("FzfLua grep_cword"),
            { silent = true, desc = "FzfLua grep cword" },
        },
        {
            "W",
            keymap.cmd("FzfLua grep_cWORD"),
            { silent = true, desc = "FzfLua grep cWORD" },
        },
        {
            "v",
            keymap.cmd("FzfLua grep_visual"),
            { silent = true, desc = "FzfLua grep visual" },
        },
        {
            "p",
            keymap.cmd("FzfLua grep_project"),
            { silent = true, desc = "FzfLua grep project" },
        },
        {
            "G",
            keymap.cmd("FzfLua live_grep"),
            { silent = true, desc = "FzfLua live grep" },
        },
        {
            "r",
            keymap.cmd("FzfLua live_grep_resume"),
            { silent = true, desc = "FzfLua live grep resume" },
        },
        {
            "o",
            keymap.cmd("FzfLua live_grep_glob"),
            { silent = true, desc = "FzfLua live grep glob" },
        },
        {
            "n",
            keymap.cmd("FzfLua live_grep_native"),
            { silent = true, desc = "FzfLua live grep native" },
        },
        {
            "b",
            keymap.cmd("FzfLua grep_curbuf"),
            { silent = true, desc = "FzfLua grep curbuf" },
        },
        {
            "B",
            keymap.cmd("FzfLua lgrep_curbuf"),
            { silent = true, desc = "FzfLua lgrep curbuf" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<Esc>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_tags = [[
                          FZF TAGS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Tags                        _t_ │ _b_                      Btags
Tags grep                   _g_ │ _v_           Tags grep visual
Tags grep cword             _w_ │ _L_             Tags live grep
Tags grep cWORD             _W_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.fzf_tags = Hydra({
    name = "FZF TAGS",
    hint = fzf_tags,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    -- mode = { "n", "x", "v" },
    -- body = ";zt",
    heads = {
        {
            "t",
            keymap.cmd("FzfLua tags"),
            { silent = true, desc = "FzfLua tags" },
        },
        {
            "g",
            keymap.cmd("FzfLua tags_grep"),
            { silent = true, desc = "FzfLua tags grep" },
        },
        {
            "w",
            keymap.cmd("FzfLua tags_grep_cword"),
            { silent = true, desc = "FzfLua tags grep cword" },
        },
        {
            "W",
            keymap.cmd("FzfLua tags_grep_cWORD"),
            { silent = true, desc = "FzfLua tags grep cWORD" },
        },
        {
            "b",
            keymap.cmd("FzfLua btags"),
            { silent = true, desc = "FzfLua btags" },
        },
        {
            "v",
            keymap.cmd("FzfLua tags_grep_visual"),
            { silent = true, desc = "FzfLua tags grep visual" },
        },
        {
            "L",
            keymap.cmd("FzfLua tags_live_grep"),
            { silent = true, desc = "FzfLua tags_live_grep" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<Esc>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_git = [[
                           FZF GIT

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Git files                   _f_ │ _s_                 Git status
Git commits                 _c_ │ _r_               Git branches
Git bcommits                _b_ │ _t_                  Git stash

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.fzf_git = Hydra({
    name = "FZF GIT",
    hint = fzf_git,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    -- mode = { "n", "x", "v" },
    -- body = ";zg",
    heads = {
        {
            "f",
            keymap.cmd("FzfLua git_files"),
            { silent = true, desc = "FzfLua git files" },
        },
        {
            "c",
            keymap.cmd("FzfLua git_commits"),
            { silent = true, desc = "FzfLua git commits" },
        },
        {
            "b",
            keymap.cmd("FzfLua git_bcommits"),
            { silent = true, desc = "FzfLua git bcommits" },
        },
        {
            "s",
            keymap.cmd("FzfLua git_status"),
            { silent = true, desc = "FzfLua git status" },
        },
        {
            "r",
            keymap.cmd("FzfLua git_branches"),
            { silent = true, desc = "FzfLua git branches" },
        },
        {
            "t",
            keymap.cmd("FzfLua git_stash"),
            { silent = true, desc = "FzfLua git stash" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<Esc>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_lsp = [[
                          FZF LSP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Lsp references              _r_ │ _a_           Lsp code actions
Lsp definitions             _d_ │ _i_         Lsp incoming calls
Lsp declarations            _D_ │ _o_         Lsp outgoing calls
Lsp typedefs                _t_ │ _f_                 Lsp finder
Lsp implementations         _m_ │ _gd_      Diagnostics document
Lsp document symbols       _sd_ │ _gw_     Diagnostics workspace
Lsp workspace symbols      _sw_ │ _gD_       Lsp_doc diagnostics
Lsp live workspace symbols _sl_ │ _gW_ Lsp workspace diagnostics

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.fzf_lsp = Hydra({
    name = "FZF LSP",
    hint = fzf_lsp,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    -- mode = { "n", "x", "v" },
    -- body = ";zl",
    heads = {
        {
            "r",
            keymap.cmd("FzfLua lsp_references"),
            { silent = true, desc = "FzfLua lsp references" },
        },
        {
            "d",
            keymap.cmd("FzfLua lsp_definitions"),
            { silent = true, desc = "FzfLua lsp definitions" },
        },
        {
            "D",
            keymap.cmd("FzfLua lsp_declarations"),
            { silent = true, desc = "FzfLua lsp declarations" },
        },
        {
            "t",
            keymap.cmd("FzfLua lsp_typedefs"),
            { silent = true, desc = "FzfLua lsp typedefs" },
        },
        {
            "m",
            keymap.cmd("FzfLua lsp_implementations"),
            { silent = true, desc = "FzfLua lsp implementations" },
        },
        {
            "sd",
            keymap.cmd("FzfLua lsp_document_symbols"),
            { silent = true, desc = "FzfLua lsp document symbols" },
        },
        {
            "sw",
            keymap.cmd("FzfLua lsp_workspace_symbols"),
            { silent = true, desc = "FzfLua lsp workspace symbols" },
        },
        {
            "sl",
            keymap.cmd("FzfLua lsp_live_workspace_symbols"),
            { silent = true, desc = "FzfLua lsp live workspace symbols" },
        },
        {
            "a",
            keymap.cmd("FzfLua lsp_code_actions"),
            { silent = true, desc = "FzfLua lsp_code_actions" },
        },
        {
            "i",
            keymap.cmd("FzfLua lsp_incoming_calls"),
            { silent = true, desc = "FzfLua lsp_incoming_calls" },
        },
        {
            "o",
            keymap.cmd("FzfLua lsp_outgoing_calls"),
            { silent = true, desc = "FzfLua lsp_outgoing_calls" },
        },
        {
            "f",
            keymap.cmd("FzfLua lsp_finder"),
            { silent = true, desc = "FzfLua lsp_finder" },
        },
        {
            "gd",
            keymap.cmd("FzfLua diagnostics_document"),
            { silent = true, desc = "FzfLua diagnostics_document" },
        },
        {
            "gw",
            keymap.cmd("FzfLua diagnostics_workspace"),
            { silent = true, desc = "FzfLua diagnostics_workspace" },
        },
        {
            "gD",
            keymap.cmd("FzfLua lsp_document_diagnostics"),
            { silent = true, desc = "FzfLua lsp_document_diagnostics" },
        },
        {
            "gW",
            keymap.cmd("FzfLua lsp_workspace_diagnostics"),
            { silent = true, desc = "FzfLua lsp_workspace_diagnostics" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<Esc>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_dap = [[
                           FZF DAP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Dap commands                _m_ │ _v_              Dap variables
Dap configurations          _c_ │ _f_                 Dap frames
Dap breakpoints             _b_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.fzf_dap = Hydra({
    name = "FZF DAP",
    hint = fzf_dap,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    -- mode = { "n", "x", "v" },
    -- body = ";zd",
    heads = {
        {
            "m",
            keymap.cmd("FzfLua dap_commands"),
            { silent = true, desc = "FzfLua dap commands" },
        },
        {
            "c",
            keymap.cmd("FzfLua dap_configurations"),
            { silent = true, desc = "FzfLua dap configurations" },
        },
        {
            "b",
            keymap.cmd("FzfLua dap_breakpoints"),
            { silent = true, desc = "FzfLua dap breakpoints" },
        },
        {
            "v",
            keymap.cmd("FzfLua dap_variables"),
            { silent = true, desc = "FzfLua dap variables" },
        },
        {
            "f",
            keymap.cmd("FzfLua dap_frames"),
            { silent = true, desc = "FzfLua dap frames" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<Esc>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_misc = [[
                          FZF MISC

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Help tags                   _t_ │ _m_                      Marks
Man pages                   _M_ │ _J_                      Jumps
Highlights                  _H_ │ _g_                    Changes
Autocmds                    _A_ │ _r_                  Registers
Commands                    _c_ │ _T_                   Tagstack
Command history             _C_ │ _K_                    Keymaps
Search history              _I_ │ _f_                  Filetypes

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.fzf_misc = Hydra({
    name = "FZF MISC",
    hint = fzf_misc,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    -- mode = { "n", "x", "v" },
    -- body = ";zm",
    heads = {
        {
            "t",
            keymap.cmd("FzfLua help_tags"),
            { silent = true, desc = "FzfLua help tags" },
        },
        {
            "M",
            keymap.cmd("FzfLua man_pages"),
            { silent = true, desc = "FzfLua man pages" },
        },
        {
            "H",
            keymap.cmd("FzfLua highlights"),
            { silent = true, desc = "FzfLua highlights" },
        },
        {
            "A",
            keymap.cmd("FzfLua autocmds"),
            { silent = true, desc = "FzfLua autocmds" },
        },
        {
            "c",
            keymap.cmd("FzfLua commands"),
            { silent = true, desc = "FzfLua commands" },
        },
        {
            "C",
            keymap.cmd("FzfLua command_history"),
            { silent = true, desc = "FzfLua command history" },
        },
        {
            "I",
            keymap.cmd("FzfLua search_history"),
            { silent = true, desc = "FzfLua search history" },
        },
        {
            "m",
            keymap.cmd("FzfLua marks"),
            { silent = true, desc = "FzfLua marks" },
        },
        {
            "J",
            keymap.cmd("FzfLua jumps"),
            { silent = true, desc = "FzfLua jumps" },
        },
        {
            "g",
            keymap.cmd("FzfLua changes"),
            { silent = true, desc = "FzfLua changes" },
        },
        {
            "r",
            keymap.cmd("FzfLua registers"),
            { silent = true, desc = "FzfLua registers" },
        },
        {
            "T",
            keymap.cmd("FzfLua tagstack"),
            { silent = true, desc = "FzfLua tagstack" },
        },
        {
            "K",
            keymap.cmd("FzfLua keymaps"),
            { silent = true, desc = "FzfLua keymaps" },
        },
        {
            "f",
            keymap.cmd("FzfLua filetypes"),
            { silent = true, desc = "FzfLua filetypes" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
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
