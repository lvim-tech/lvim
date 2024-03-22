local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local location_hint = [[
                                         COMMON

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Neotree                          _<C-c><C-f>_ │ _<Leader>=_                 LVIM file manager
Ranger                                _<A-r>_ │ _<A-f>_                                  Vifm
Mini files                        _<Leader>i_ │

Search files (FZF)                _<Leader>f_ │ _<Leader>s_             (FZF) Search in files
Search buffers (FZF)              _<Leader>b_ │

Search files (Telescope)              _<A-,>_ │ _<A-.>_           (Telescope) Search in files
Search buffers (Telescope)            _<A-b>_ │

Show diagnostic next                     _dn_ │ _dp_                     Show diagnostic prev
Show diagnostic current                  _dc_ │

Symbols outline                       _<A-v>_ │ _<C-c>v_                             Navbuddy
Lvim diagnostics                 _<C-c><C-h>_ │ _<C-c><C-v>_                          Trouble

Previous hunk                         _<A-[>_ │ _<A-]>_                             Next hunk
View hunk                             _<A-;>_ │ _<C-c>b_                           Blame line
Blame line view                      _<C-c>m_ │

Lazygit                               _<A-g>_ │ _<A-n>_                                Neogit
Lvim forgit                           _<A-t>_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.common = Hydra({
    name = "COMMON",
    hint = location_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            float_opts = {
                border = "single",
            },
        },
    },
    mode = { "n", "x", "v" },
    body = ";a",
    heads = {
        {
            "<C-c><C-f>",
            keymap.cmd("Neotree toggle left"),
            { nowait = true, silent = true, desc = "Neotree" },
        },
        {
            "<Leader>=",
            keymap.cmd("LvimFileManager"),
            { nowait = true, silent = true, desc = "LVIM file manager" },
        },
        {
            "<A-r>",
            keymap.cmd("Ranger"),
            { nowait = true, silent = true, desc = "Ranger" },
        },
        {
            "<A-f>",
            keymap.cmd("Vifm"),
            { nowait = true, silent = true, desc = "Vifm" },
        },
        {
            "<Leader>i",
            function()
                require("mini.files").open()
            end,
            { nowait = true, silent = true, desc = "Mini files" },
        },
        {
            "<Leader>f",
            keymap.cmd("FzfLua files"),
            { nowait = true, silent = true, desc = "Fzf search files" },
        },
        {
            "<Leader>s",
            keymap.cmd("FzfLua live_grep"),
            { nowait = true, silent = true, desc = "Fzf search in files" },
        },
        {
            "<Leader>b",
            keymap.cmd("FzfLua buffers"),
            { nowait = true, silent = true, desc = "Fzf search buffers" },
        },
        {
            "<A-,>",
            keymap.cmd("Telescope find_files"),
            { nowait = true, silent = true, desc = "Telescope search files" },
        },
        {
            "<A-.>",
            keymap.cmd("Telescope live_grep"),
            { nowait = true, silent = true, desc = "Telescope search in files" },
        },
        {
            "<A-b>",
            keymap.cmd("Telescope buffers"),
            { nowait = true, silent = true, desc = "Telescope search buffers" },
        },
        {
            "<C-c><C-h>",
            keymap.cmd("LvimDiagnostics"),
            { nowait = true, silent = true, desc = "Prev" },
        },
        {
            "dc",
            keymap.cmd("LspShowDiagnosticCurrent"),
            { nowait = true, silent = true, desc = "Show diagnostic current" },
        },
        {
            "dn",
            keymap.cmd("LspShowDiagnosticNext"),
            { nowait = true, silent = true, desc = "Show diagnostic next" },
        },
        {
            "dp",
            keymap.cmd("LspShowDiagnosticPrev"),
            { nowait = true, silent = true, desc = "Show diagnostic prev" },
        },
        {
            "<A-v>",
            keymap.cmd("SymbolsOutline"),
            { nowait = true, silent = true, desc = "Symbols outline" },
        },
        {
            "<C-c>v",
            keymap.cmd("Navbuddy"),
            { nowait = true, silent = true, desc = "Navbuddy" },
        },
        {
            "<C-c><C-h>",
            keymap.cmd("LvimDiagnostics"),
            { nowait = true, silent = true, desc = "Lvim diagnostics" },
        },
        {
            "<C-c><C-v>",
            keymap.cmd("Trouble"),
            { nowait = true, silent = true, desc = "Trouble" },
        },
        {
            "<A-[>",
            keymap.cmd("GitSignsPrevHunk"),
            { nowait = true, silent = true, desc = "Prev hunk" },
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
            { nowait = true, silent = true, desc = "Blame line" },
        },
        {
            "<C-c>m",
            keymap.cmd("GitSignsBlameLine"),
            { nowait = true, silent = true, desc = "Blame line view" },
        },
        {
            "<A-g>",
            keymap.cmd("Lazygit"),
            { nowait = true, silent = true, desc = "Lazygit" },
        },
        {
            "<A-n>",
            keymap.cmd("Neogit"),
            { nowait = true, silent = true, desc = "Neogit" },
        },
        {
            "<A-t>",
            keymap.cmd("LvimForgit"),
            { nowait = true, silent = true, desc = "LvimForgit" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
