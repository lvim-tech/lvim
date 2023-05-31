local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local explorer_hint = [[
                          EXPLORER

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Neotree left                _e_ │ _b_       Neotree buffers left
Neotree git status left     _g_ │ _d_   Neotree diagnostics left

Neotree float               _E_ │ _B_      Neotree buffers float
Neotree git status float    _G_ │ _D_  Neotree diagnostics float

Ranger                      _r_ │ _v_                       Vifm
Oil                         _O_ │ _f_          LVIM file manager

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

Hydra({
    name = "EXPLORER",
    hint = explorer_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";e",
    heads = {
        {
            "e",
            keymap.cmd("Neotree left"),
            { nowait = true, silent = true, desc = "Neotree left" },
        },
        {
            "b",
            keymap.cmd("Neotree buffers left"),
            { nowait = true, silent = true, desc = "Neotree buffers left" },
        },
        {
            "g",
            keymap.cmd("Neotree git_status left"),
            { nowait = true, silent = true, desc = "Neotree git status left" },
        },
        {
            "d",
            keymap.cmd("Neotree diagnostics left"),
            { nowait = true, silent = true, desc = "Neotree diagnostics left" },
        },
        {
            "E",
            keymap.cmd("Neotree float"),
            { nowait = true, silent = true, desc = "Neotree float" },
        },
        {
            "B",
            keymap.cmd("Neotree buffers float"),
            { nowait = true, silent = true, desc = "Neotree buffers float" },
        },
        {
            "G",
            keymap.cmd("Neotree git_status float"),
            { nowait = true, silent = true, desc = "Neotree git status float" },
        },
        {
            "D",
            keymap.cmd("Neotree diagnostics float"),
            { nowait = true, silent = true, desc = "Neotree diagnostics float" },
        },
        {
            "r",
            keymap.cmd("Ranger"),
            { nowait = true, silent = true, desc = "Ranger" },
        },
        {
            "v",
            keymap.cmd("Vifm"),
            { nowait = true, silent = true, desc = "Vifm" },
        },
        {
            "O",
            keymap.cmd("Oil"),
            { nowait = true, silent = true, desc = "Oil" },
        },
        {
            "f",
            keymap.cmd("LvimFileManager"),
            { nowait = true, silent = true, desc = "LVIM file manager" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
