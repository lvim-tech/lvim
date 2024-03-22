local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")
local icons = require("configs.base.ui.icons")

local M = {}

local git_hint = [[
                                           GIT

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Neogit                                _<A-n>_ │ _<A-g>_                               LazyGit
Diffview ]] .. icons.common.dot .. [[                      _<C-c><C-c>d_ │ _<C-c><C-c>s_                      ]] .. icons.common.dot .. [[ GitSigns
Lvim forgit                           _<A-t>_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.git_menu = Hydra({
    name = "GIT",
    hint = git_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    mode = { "n", "x", "v" },
    body = ";g",
    heads = {
        {
            "<A-n>",
            keymap.cmd("Neogit"),
            { nowait = true, silent = true, desc = "Neogit" },
        },
        {
            "<A-g>",
            keymap.cmd("Lazygit"),
            { nowait = true, silent = true, desc = "Lazygit" },
        },
        {
            "<C-c><C-c>d",
            function()
                M.diff_view:activate()
            end,
        },
        {
            "<C-c><C-c>s",
            function()
                M.git_signs:activate()
            end,
        },
        {
            "<A-t>",
            keymap.cmd("LvimForgit"),
            { nowait = true, silent = true, desc = "LvimForgit" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

local diffview_hint = [[
                                        DIFF VIEW

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
DiffView open                   _<C-c><C-c>o_ │ _<C-c><C-c>c_                  DiffView close
DiffView log                    _<C-c><C-c>l_ │ _<C-c><C-c>r_                DiffView refresh
DiffView focus files            _<C-c><C-c>f_ │ _<C-c><C-c>h_           DiffView file history
DiffView toggle files           _<C-c><C-c>t_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.diff_view = Hydra({
    name = "DIFF VIEW",
    hint = diffview_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    heads = {
        {
            "<C-c><C-c>o",
            keymap.cmd("DiffviewOpen"),
            { nowait = true, silent = true, desc = "DiffView open" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("DiffviewClose"),
            { nowait = true, silent = true, desc = "DiffView close" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("DiffviewLog"),
            { nowait = true, silent = true, desc = "DiffView log" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("DiffviewRefresh"),
            { nowait = true, silent = true, desc = "DiffView refresh" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("DiffviewFocusFiles"),
            { nowait = true, silent = true, desc = "DiffView focus files" },
        },
        {
            "<C-c><C-c>h",
            keymap.cmd("DiffviewFileHistory"),
            { nowait = true, silent = true, desc = "DiffView file history" },
        },
        {
            "<C-c><C-c>t",
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

local gitsigns_hint = [[
                                            GIT

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Previous hunk                         _<A-[>_ │ _<A-]>_                             Next hunk
View hunk                             _<A-;>_ │

Blame line view                      _<C-c>m_ │ _<C-c>b_                           Blame line

Stage hunk                      _<C-c><C-c>s_ │ _<C-c><C-c>u_                 Undo stage hunk
Reset hunk                      _<C-c><C-c>r_ │ _<C-c><C-c>R_                    Reset buffer
Blame full                      _<C-c><C-c>f_ │ _<C-c><C-c>q_                Send to quickfix
Toggle linehl                   _<C-c><C-c>h_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
                                       back │ _<BS>_
]]

M.git_signs = Hydra({
    name = "GIT SIGNS",
    hint = gitsigns_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    heads = {
        {
            "<A-[>",
            keymap.cmd("GitSignsPreviewHunk"),
            { nowait = true, silent = true, desc = "Previous hunk" },
        },
        {
            "<A-]>",
            keymap.cmd("GitSignsNextHunk"),
            { nowait = true, silent = true, desc = "Next hunk" },
        },
        {
            "<A-;>",
            keymap.cmd("GitSignsPreviewHunk"),
            { nowait = true, silent = true, desc = "View hunk" },
        },
        {
            "<C-c>b",
            keymap.cmd("GitSignsToggleLineBlame"),
            { nowait = true, silent = true, desc = "blame line" },
        },
        {
            "<C-c>m",
            keymap.cmd("GitSignsBlameLine"),
            { nowait = true, silent = true, desc = "Blame line view" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("GitSignsStageHunk"),
            { nowait = true, silent = true, desc = "Stage hunk" },
        },
        {
            "<C-c><C-c>u",
            keymap.cmd("GitSignsUndoStageHunk"),
            { nowait = true, silent = true, desc = "Undo stage hunk" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("GitSignsResetHunk"),
            { nowait = true, silent = true, desc = "Reset hunk" },
        },
        {
            "<C-c><C-c>R",
            keymap.cmd("GitSignsResetBuffer"),
            { nowait = true, silent = true, desc = "Reset buffer" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("GitSignsBlameFull"),
            { nowait = true, silent = true, desc = "Blame full" },
        },
        {
            "<C-c><C-c>q",
            keymap.cmd("Gitsigns setqflist"),
            { nowait = true, silent = true, desc = "Send to quickfix" },
        },
        {
            "<C-c><C-c>h",
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
