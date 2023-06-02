local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local location_hint = [[
                           COMMON

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Neotree                     _e_ │ _u_          LVIM file manager

Search files                _f_ │ _w_            Search in files

LvimDiagnostics             _d_ │ _c_    Show diagnostic current
Show diagnostic next        _n_ │ _p_       Show diagnostic prev

Symbols outline             _O_ │ _t_                   Terminal

Previous hunk               _[_ │ _]_                  Next hunk
View hunk                   _v_ │ _b_                 Blame line

Lazygit                     _L_ │ _g_                Lvim forgit

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

M.common = Hydra({
    name = "COMMON",
    hint = location_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";a",
    heads = {
        {
            "e",
            keymap.cmd("Neotree left"),
            { nowait = true, silent = true, desc = "Neotree" },
        },
        {
            "u",
            keymap.cmd("LvimFileManager"),
            { nowait = true, silent = true, desc = "LVIM file manager" },
        },
        {
            "f",
            keymap.cmd("FzfLua files"),
            { nowait = true, silent = true, desc = "Search files" },
        },
        {
            "w",
            keymap.cmd("FzfLua live_grep"),
            { nowait = true, silent = true, desc = "Search in files" },
        },
        {
            "d",
            keymap.cmd("LvimDiagnostics"),
            { nowait = true, silent = true, desc = "Prev" },
        },
        {
            "c",
            keymap.cmd("LspShowDiagnosticCurrent"),
            { nowait = true, silent = true, desc = "Show diagnostic current" },
        },
        {
            "n",
            keymap.cmd("LspShowDiagnosticNext"),
            { nowait = true, silent = true, desc = "Show diagnostic next" },
        },
        {
            "p",
            keymap.cmd("LspShowDiagnosticPrev"),
            { nowait = true, silent = true, desc = "Show diagnostic prev" },
        },
        {
            "O",
            keymap.cmd("SymbolsOutline"),
            { nowait = true, silent = true, desc = "Symbols outline" },
        },
        {
            "t",
            keymap.cmd("TerminalHorizontal1"),
            { nowait = true, silent = true, desc = "Terminal" },
        },
        {
            "[",
            keymap.cmd("GitSignsPreviewHunk"),
            { nowait = true, silent = true, desc = "Previous hunk" },
        },
        {
            "]",
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
            "L",
            keymap.cmd("Lazygit"),
            { nowait = true, silent = true, desc = "Lazygit" },
        },
        {
            "g",
            keymap.cmd("LvimForgit"),
            { nowait = true, silent = true, desc = "LvimForgit" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})

return M
