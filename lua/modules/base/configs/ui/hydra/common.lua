local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

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

Hydra({
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
            { silent = true, desc = "Neotree" },
        },
        {
            "u",
            keymap.cmd("LvimFileManager"),
            { silent = true, desc = "LVIM file manager" },
        },
        {
            "f",
            keymap.cmd("FzfLua files"),
            { silent = true, desc = "Search files" },
        },
        {
            "w",
            keymap.cmd("FzfLua live_grep"),
            { silent = true, desc = "Search in files" },
        },
        {
            "d",
            keymap.cmd("LvimDiagnostics"),
            { silent = true, desc = "Prev" },
        },
        {
            "c",
            keymap.cmd("LspShowDiagnosticCurrent"),
            { silent = true, desc = "Show diagnostic current" },
        },
        {
            "n",
            keymap.cmd("LspShowDiagnosticNext"),
            { silent = true, desc = "Show diagnostic next" },
        },
        {
            "p",
            keymap.cmd("LspShowDiagnosticPrev"),
            { silent = true, desc = "Show diagnostic prev" },
        },
        {
            "O",
            keymap.cmd("SymbolsOutline"),
            { silent = true, desc = "Symbols outline" },
        },
        {
            "t",
            keymap.cmd("TerminalHorizontal1"),
            { silent = true, desc = "Terminal" },
        },
        {
            "[",
            keymap.cmd("GitSignsPreviewHunk"),
            { silent = true, desc = "Previous hunk" },
        },
        {
            "]",
            keymap.cmd("GitSignsNextHunk"),
            { silent = true, desc = "Next hunk" },
        },
        {
            "v",
            keymap.cmd("GitSignsPreviewHunk"),
            { silent = true, desc = "View hunk" },
        },
        {
            "b",
            keymap.cmd("GitSignsBlameLine"),
            { silent = true, desc = "Blame line" },
        },
        {
            "L",
            keymap.cmd("Lazygit"),
            { silent = true, desc = "Lazygit" },
        },
        {
            "g",
            keymap.cmd("LvimForgit"),
            { silent = true, desc = "LvimForgit" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
