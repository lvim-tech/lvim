local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local git_menu = [[
                             GIT

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Neogit                      _n_ │ _L_                    LazyGit
Diffview                    _d_ │ _s_                   GitSigns
Lvim forgit                 _f_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<C-q>_
]]

M.git_menu = Hydra({
    name = "GIT",
    hint = git_menu,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";g",
    heads = {
        {
            "d",
            function()
                M.diff_view:activate()
            end,
        },
        {
            "s",
            function()
                M.git_signs:activate()
            end,
        },
        {
            "n",
            keymap.cmd("Neogit"),
            { nowait = true, silent = true, desc = "Neogit" },
        },
        {
            "L",
            keymap.cmd("Lazygit"),
            { nowait = true, silent = true, desc = "Lazygit" },
        },
        {
            "f",
            keymap.cmd("LvimForgit"),
            { nowait = true, silent = true, desc = "LvimForgit" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

local diff_view = [[
                          DIFF VIEW

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
DiffView open               _o_ │ _c_             DiffView close
DiffView log                _g_ │ _r_           DiffView refresh
DiffView focus files        _F_ │ _f_      DiffView file history
DiffView toggle files       _t_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<C-q>_  │  back => _<BS>_
]]

M.diff_view = Hydra({
    name = "DIFF VIEW",
    hint = diff_view,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    heads = {
        {
            "o",
            keymap.cmd("DiffviewOpen"),
            { nowait = true, silent = true, desc = "DiffView open" },
        },
        {
            "c",
            keymap.cmd("DiffviewClose"),
            { nowait = true, silent = true, desc = "DiffView close" },
        },
        {
            "g",
            keymap.cmd("DiffviewLog"),
            { nowait = true, silent = true, desc = "DiffView log" },
        },
        {
            "r",
            keymap.cmd("DiffviewRefresh"),
            { nowait = true, silent = true, desc = "DiffView refresh" },
        },
        {
            "F",
            keymap.cmd("DiffviewFocusFiles"),
            { nowait = true, silent = true, desc = "DiffView focus files" },
        },
        {
            "f",
            keymap.cmd("DiffviewFileHistory"),
            { nowait = true, silent = true, desc = "DiffView file history" },
        },
        {
            "t",
            keymap.cmd("DiffviewToggleFiles"),
            { nowait = true, silent = true, desc = "DiffView toggle files" },
        },
        {
            "<BS>",
            function()
                M.git_menu:activate()
            end,
        },
        {
            "<C-q>",
            nil,
            { exit = true, desc = false },
        },
    },
})

local git_signs = [[
                          GITSIGNS

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Previous hunk               _p_ │ _n_                  Next hunk
View hunk                   _v_ │ _b_                 Blame line
Stage hunk                  _s_ │ _S_            Undo stage hunk
Reset hunk                  _r_ │ _R_               Reset buffer
Blame full                  _f_ │ _q_           Send to quickfix
Toggle linehl               _H_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
               exit => _<Esc>_  │  back => _<BS>_
]]

M.git_signs = Hydra({
    name = "GIT SIGNS",
    hint = git_signs,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    heads = {
        {
            "p",
            keymap.cmd("GitSignsPreviewHunk"),
            { nowait = true, silent = true, desc = "Previous hunk" },
        },
        {
            "n",
            keymap.cmd("GitSignsNextHunk"),
            { nowait = true, silent = true, desc = "Next hunk" },
        },
        {
            "v",
            keymap.cmd("GitSignsPreviewHunk"),
            { nowait = true, silent = true, desc = "View hunk" },
        },
        {
            "b",
            keymap.cmd("GitSignsBlameLine"),
            { nowait = true, silent = true, desc = "Blame line" },
        },
        {
            "s",
            keymap.cmd("GitSignsStageHunk"),
            { nowait = true, silent = true, desc = "Stage hunk" },
        },
        {
            "S",
            keymap.cmd("GitSignsUndoStageHunk"),
            { nowait = true, silent = true, desc = "Undo stage hunk" },
        },
        {
            "r",
            keymap.cmd("GitSignsResetHunk"),
            { nowait = true, silent = true, desc = "Reset hunk" },
        },
        {
            "R",
            keymap.cmd("GitSignsResetBuffer"),
            { nowait = true, silent = true, desc = "Reset buffer" },
        },
        {
            "f",
            keymap.cmd("GitSignsBlameFull"),
            { nowait = true, silent = true, desc = "Blame full" },
        },
        {
            "q",
            keymap.cmd("Gitsigns setqflist"),
            { nowait = true, silent = true, desc = "Send to quickfix" },
        },
        {
            "H",
            keymap.cmd("GitSignsToggleLinehl"),
            { nowait = true, silent = true, desc = "Toggle linehl" },
        },
        {
            "<BS>",
            function()
                M.git_menu:activate()
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
