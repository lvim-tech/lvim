local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")
local icons = require("configs.base.ui.icons")

local M = {}

local fzf_menu = [[
                                           FZF

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Navigation ]] .. icons.common.dot .. [[                              _n_ │ _s_                                  ]] .. icons.common.dot .. [[ Search
Tags ]] .. icons.common.dot .. [[                                    _t_ │ _i_                                     ]] .. icons.common.dot .. [[ GIT
LSP ]] .. icons.common.dot .. [[                                     _l_ │ _p_                                     ]] .. icons.common.dot .. [[ DAP
Misc ]] .. icons.common.dot .. [[                                    _m_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.fzf_menu = Hydra({
    name = "FZF",
    hint = fzf_menu,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    mode = { "n", "x", "v" },
    body = ";f",
    heads = {
        {
            "n",
            function()
                M.fzf_navigation:activate()
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
            "i",
            function()
                M.fzf_git:activate()
            end,
        },
        {
            "l",
            function()
                M.fzf_lsp:activate()
            end,
        },
        {
            "p",
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
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

local fzf_navigation_hydra = [[
                                     FZF NAVIGATION

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Buffers                           _<Leader>b_ │ _<C-c><C-c>q_                       Quick fix
Files                             _<Leader>f_ │ _<C-c><C-c>Q_                 Quick fix stack
Lines                           _<C-c><C-c>l_ │ _<C-c><C-c>c_                        Loc list
B lines                         _<C-c><C-c>L_ │ _<C-c><C-c>C_                  Loc list stack
Old files                       _<C-c><C-c>o_ │ _<C-c><C-c>t_                            Tabs

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.fzf_navigation = Hydra({
    name = "FZF BUFFERS AND FILES",
    hint = fzf_navigation_hydra,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        {
            "<Leader>b",
            keymap.cmd("FzfLua buffers"),
            { nowait = true, silent = true, desc = "FzfLua buffers" },
        },
        {
            "<Leader>f",
            keymap.cmd("FzfLua files"),
            { nowait = true, silent = true, desc = "FzfLua files" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("FzfLua lines"),
            { nowait = true, silent = true, desc = "FzfLua lines" },
        },
        {
            "<C-c><C-c>L",
            keymap.cmd("FzfLua blines"),
            { nowait = true, silent = true, desc = "FzfLua blines" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("FzfLua oldfiles"),
            { nowait = true, silent = true, desc = "FzfLua oldfiles" },
        },
        {
            "<C-c><C-c>q",
            keymap.cmd("FzfLua quickfix"),
            { nowait = true, silent = true, desc = "FzfLua quickfix" },
        },
        {
            "<C-c><C-c>Q",
            keymap.cmd("FzfLua quickfix_stack"),
            { nowait = true, silent = true, desc = "FzfLua quickfix stack" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("FzfLua loclist"),
            { nowait = true, silent = true, desc = "FzfLua loclist" },
        },
        {
            "<C-c><C-c>C",
            keymap.cmd("FzfLua loclist_stack"),
            { nowait = true, silent = true, desc = "FzfLua loclist stack" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("FzfLua tabs"),
            { nowait = true, silent = true, desc = "FzfLua tabs" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_search_hydra = [[
                                       FZF SEARCH

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Live grep                         _<Leader>s_ │ _<C-c><C-c>g_                            Grep
Grep last                       _<C-c><C-c>l_ │ _<C-c><C-c>r_                Live grep resume
Grep cword                      _<C-c><C-c>w_ │ _<C-c><C-c>o_                  Live grep glob
Grep cWORD                      _<C-c><C-c>W_ │ _<C-c><C-c>n_                Live grep native
Grep visual                     _<C-c><C-c>v_ │ _<C-c><C-c>b_                     Grep curbuf
Grep project                    _<C-c><C-c>p_ │ _<C-c><C-c>B_                    Lgrep curbuf

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.fzf_search = Hydra({
    name = "FZF SEARCH",
    hint = fzf_search_hydra,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        {
            "<Leader>s",
            keymap.cmd("FzfLua live_grep"),
            { nowait = true, silent = true, desc = "FzfLua live grep" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("FzfLua grep_last"),
            { nowait = true, silent = true, desc = "FzfLua grep last" },
        },
        {
            "<C-c><C-c>w",
            keymap.cmd("FzfLua grep_cword"),
            { nowait = true, silent = true, desc = "FzfLua grep cword" },
        },
        {
            "<C-c><C-c>W",
            keymap.cmd("FzfLua grep_cWORD"),
            { nowait = true, silent = true, desc = "FzfLua grep cWORD" },
        },
        {
            "<C-c><C-c>v",
            keymap.cmd("FzfLua grep_visual"),
            { nowait = true, silent = true, desc = "FzfLua grep visual" },
        },
        {
            "<C-c><C-c>p",
            keymap.cmd("FzfLua grep_project"),
            { nowait = true, silent = true, desc = "FzfLua grep project" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("FzfLua grep"),
            { nowait = true, silent = true, desc = "FzfLua grep" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("FzfLua live_grep_resume"),
            { nowait = true, silent = true, desc = "FzfLua live grep resume" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("FzfLua live_grep_glob"),
            { nowait = true, silent = true, desc = "FzfLua live grep glob" },
        },
        {
            "<C-c><C-c>n",
            keymap.cmd("FzfLua live_grep_native"),
            { nowait = true, silent = true, desc = "FzfLua live grep native" },
        },
        {
            "<C-c><C-c>b",
            keymap.cmd("FzfLua grep_curbuf"),
            { nowait = true, silent = true, desc = "FzfLua grep curbuf" },
        },
        {
            "<C-c><C-c>B",
            keymap.cmd("FzfLua lgrep_curbuf"),
            { nowait = true, silent = true, desc = "FzfLua lgrep curbuf" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_tags_hydra = [[
                                        FZF TAGS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Tags                            _<C-c><C-c>t_ │ _<C-c><C-c>b_                           Btags
Tags grep                       _<C-c><C-c>g_ │ _<C-c><C-c>v_                Tags grep visual
Tags grep cword                 _<C-c><C-c>w_ │ _<C-c><C-c>l_                  Tags live grep
Tags grep cWORD                 _<C-c><C-c>W_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.fzf_tags = Hydra({
    name = "FZF TAGS",
    hint = fzf_tags_hydra,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        {
            "<C-c><C-c>t",
            keymap.cmd("FzfLua tags"),
            { nowait = true, silent = true, desc = "FzfLua tags" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("FzfLua tags_grep"),
            { nowait = true, silent = true, desc = "FzfLua tags grep" },
        },
        {
            "<C-c><C-c>w",
            keymap.cmd("FzfLua tags_grep_cword"),
            { nowait = true, silent = true, desc = "FzfLua tags grep cword" },
        },
        {
            "<C-c><C-c>W",
            keymap.cmd("FzfLua tags_grep_cWORD"),
            { nowait = true, silent = true, desc = "FzfLua tags grep cWORD" },
        },
        {
            "<C-c><C-c>b",
            keymap.cmd("FzfLua btags"),
            { nowait = true, silent = true, desc = "FzfLua btags" },
        },
        {
            "<C-c><C-c>v",
            keymap.cmd("FzfLua tags_grep_visual"),
            { nowait = true, silent = true, desc = "FzfLua tags grep visual" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("FzfLua tags_live_grep"),
            { nowait = true, silent = true, desc = "FzfLua tags_live_grep" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_git_hydra = [[
                                        FZF GIT

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Git files                       _<C-c><C-c>f_ │ _<C-c><C-c>s_                      Git status
Git commits                     _<C-c><C-c>c_ │ _<C-c><C-c>r_                    Git branches
Git bcommits                    _<C-c><C-c>b_ │ _<C-c><C-c>t_                       Git stash

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.fzf_git = Hydra({
    name = "FZF GIT",
    hint = fzf_git_hydra,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        {
            "<C-c><C-c>f",
            keymap.cmd("FzfLua git_files"),
            { nowait = true, silent = true, desc = "FzfLua git files" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("FzfLua git_commits"),
            { nowait = true, silent = true, desc = "FzfLua git commits" },
        },
        {
            "<C-c><C-c>b",
            keymap.cmd("FzfLua git_bcommits"),
            { nowait = true, silent = true, desc = "FzfLua git bcommits" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("FzfLua git_status"),
            { nowait = true, silent = true, desc = "FzfLua git status" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("FzfLua git_branches"),
            { nowait = true, silent = true, desc = "FzfLua git branches" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("FzfLua git_stash"),
            { nowait = true, silent = true, desc = "FzfLua git stash" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_lsp_hydra = [[
                                        FZF LSP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Lsp references                  _<C-c><C-c>r_ │ _<C-c><C-c>a_                Lsp code actions
Lsp definitions                 _<C-c><C-c>d_ │ _<C-c><C-c>i_              Lsp incoming calls
Lsp declarations                _<C-c><C-c>D_ │ _<C-c><C-c>o_              Lsp outgoing calls
Lsp typedefs                    _<C-c><C-c>t_ │ _<C-c><C-c>f_                      Lsp finder
Lsp implementations             _<C-c><C-c>m_ │ _<C-c><C-c>dd_           Diagnostics document
Lsp document symbols           _<C-c><C-c>sd_ │ _<C-c><C-c>dw_          Diagnostics workspace
Lsp workspace symbols          _<C-c><C-c>sw_ │ _<C-c><C-c>ld_       Lsp document diagnostics
Lsp live workspace symbols     _<C-c><C-c>sl_ │ _<C-c><C-c>lw_      Lsp workspace diagnostics

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.fzf_lsp = Hydra({
    name = "FZF LSP",
    hint = fzf_lsp_hydra,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        {
            "<C-c><C-c>r",
            keymap.cmd("FzfLua lsp_references"),
            { nowait = true, silent = true, desc = "FzfLua lsp references" },
        },
        {
            "<C-c><C-c>d",
            keymap.cmd("FzfLua lsp_definitions"),
            { nowait = true, silent = true, desc = "FzfLua lsp definitions" },
        },
        {
            "<C-c><C-c>D",
            keymap.cmd("FzfLua lsp_declarations"),
            { nowait = true, silent = true, desc = "FzfLua lsp declarations" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("FzfLua lsp_typedefs"),
            { nowait = true, silent = true, desc = "FzfLua lsp typedefs" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("FzfLua lsp_implementations"),
            { nowait = true, silent = true, desc = "FzfLua lsp implementations" },
        },
        {
            "<C-c><C-c>sd",
            keymap.cmd("FzfLua lsp_document_symbols"),
            { nowait = true, silent = true, desc = "FzfLua lsp document symbols" },
        },
        {
            "<C-c><C-c>sw",
            keymap.cmd("FzfLua lsp_workspace_symbols"),
            { nowait = true, silent = true, desc = "FzfLua lsp workspace symbols" },
        },
        {
            "<C-c><C-c>sl",
            keymap.cmd("FzfLua lsp_live_workspace_symbols"),
            { nowait = true, silent = true, desc = "FzfLua lsp live workspace symbols" },
        },
        {
            "<C-c><C-c>a",
            keymap.cmd("FzfLua lsp_code_actions"),
            { nowait = true, silent = true, desc = "FzfLua lsp_code_actions" },
        },
        {
            "<C-c><C-c>i",
            keymap.cmd("FzfLua lsp_incoming_calls"),
            { nowait = true, silent = true, desc = "FzfLua lsp_incoming_calls" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("FzfLua lsp_outgoing_calls"),
            { nowait = true, silent = true, desc = "FzfLua lsp_outgoing_calls" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("FzfLua lsp_finder"),
            { nowait = true, silent = true, desc = "FzfLua lsp_finder" },
        },
        {
            "<C-c><C-c>dd",
            keymap.cmd("FzfLua diagnostics_document"),
            { nowait = true, silent = true, desc = "FzfLua diagnostics_document" },
        },
        {
            "<C-c><C-c>dw",
            keymap.cmd("FzfLua diagnostics_workspace"),
            { nowait = true, silent = true, desc = "FzfLua diagnostics_workspace" },
        },
        {
            "<C-c><C-c>ld",
            keymap.cmd("FzfLua lsp_document_diagnostics"),
            { nowait = true, silent = true, desc = "FzfLua lsp_document_diagnostics" },
        },
        {
            "<C-c><C-c>lw",
            keymap.cmd("FzfLua lsp_workspace_diagnostics"),
            { nowait = true, silent = true, desc = "FzfLua lsp_workspace_diagnostics" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_dap_hydra = [[
                                         FZF DAP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Dap commands                    _<C-c><C-c>c_ │ _<C-c><C-c>v_                   Dap variables
Dap configurations              _<C-c><C-c>f_ │ _<C-c><C-c>i_              Lsp incoming calls
Dap breakpoints                 _<C-c><C-c>b_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.fzf_dap = Hydra({
    name = "FZF DAP",
    hint = fzf_dap_hydra,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        {
            "<C-c><C-c>c",
            keymap.cmd("FzfLua dap_commands"),
            { nowait = true, silent = true, desc = "FzfLua dap commands" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("FzfLua dap_configurations"),
            { nowait = true, silent = true, desc = "FzfLua dap configurations" },
        },
        {
            "<C-c><C-c>b",
            keymap.cmd("FzfLua dap_breakpoints"),
            { nowait = true, silent = true, desc = "FzfLua dap breakpoints" },
        },
        {
            "<C-c><C-c>v",
            keymap.cmd("FzfLua dap_variables"),
            { nowait = true, silent = true, desc = "FzfLua dap variables" },
        },
        {
            "<C-c><C-c>i",
            keymap.cmd("FzfLua dap_frames"),
            { nowait = true, silent = true, desc = "FzfLua dap frames" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local fzf_misc_hydra = [[
                                        FZF MISC

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Help tags                       _<C-c><C-c>t_ │ _<C-c><C-c>m_                           Marks
Man pages                       _<C-c><C-c>M_ │ _<C-c><C-c>j_                           Jumps
Highlights                      _<C-c><C-c>h_ │ _<C-c><C-c>g_                         Changes
Autocmds                        _<C-c><C-c>a_ │ _<C-c><C-c>r_                       Registers
Commands                        _<C-c><C-c>c_ │ _<C-c><C-c>T_                        Tagstack
Command history                 _<C-c><C-c>C_ │ _<C-c><C-c>k_                         Keymaps
Search history                  _<C-c><C-c>s_ │ _<C-c><C-c>f_                       Filetypes

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.fzf_misc = Hydra({
    name = "FZF MISC",
    hint = fzf_misc_hydra,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    heads = {
        {
            "<C-c><C-c>t",
            keymap.cmd("FzfLua help_tags"),
            { nowait = true, silent = true, desc = "FzfLua help tags" },
        },
        {
            "<C-c><C-c>M",
            keymap.cmd("FzfLua man_pages"),
            { nowait = true, silent = true, desc = "FzfLua man pages" },
        },
        {
            "<C-c><C-c>h",
            keymap.cmd("FzfLua highlights"),
            { nowait = true, silent = true, desc = "FzfLua highlights" },
        },
        {
            "<C-c><C-c>a",
            keymap.cmd("FzfLua autocmds"),
            { nowait = true, silent = true, desc = "FzfLua autocmds" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("FzfLua commands"),
            { nowait = true, silent = true, desc = "FzfLua commands" },
        },
        {
            "<C-c><C-c>C",
            keymap.cmd("FzfLua command_history"),
            { nowait = true, silent = true, desc = "FzfLua command history" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("FzfLua search_history"),
            { nowait = true, silent = true, desc = "FzfLua search history" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("FzfLua marks"),
            { nowait = true, silent = true, desc = "FzfLua marks" },
        },
        {
            "<C-c><C-c>j",
            keymap.cmd("FzfLua jumps"),
            { nowait = true, silent = true, desc = "FzfLua jumps" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("FzfLua changes"),
            { nowait = true, silent = true, desc = "FzfLua changes" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("FzfLua registers"),
            { nowait = true, silent = true, desc = "FzfLua registers" },
        },
        {
            "<C-c><C-c>T",
            keymap.cmd("FzfLua tagstack"),
            { nowait = true, silent = true, desc = "FzfLua tagstack" },
        },
        {
            "<C-c><C-c>k",
            keymap.cmd("FzfLua keymaps"),
            { nowait = true, silent = true, desc = "FzfLua keymaps" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("FzfLua filetypes"),
            { nowait = true, silent = true, desc = "FzfLua filetypes" },
        },
        {
            "<BS>",
            function()
                M.fzf_menu:activate()
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
