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
    body = "<leader>e",
    heads = {
        {
            "e",
            keymap.cmd("Neotree left"),
            { silent = true, desc = "Neotree left" },
        },
        {
            "b",
            keymap.cmd("Neotree buffers left"),
            { silent = true, desc = "Neotree buffers left" },
        },
        {
            "g",
            keymap.cmd("Neotree git_status left"),
            { silent = true, desc = "Neotree git status left" },
        },
        {
            "d",
            keymap.cmd("Neotree diagnostics left"),
            { silent = true, desc = "Neotree diagnostics left" },
        },
        {
            "E",
            keymap.cmd("Neotree float"),
            { silent = true, desc = "Neotree float" },
        },
        {
            "B",
            keymap.cmd("Neotree buffers float"),
            { silent = true, desc = "Neotree buffers float" },
        },
        {
            "G",
            keymap.cmd("Neotree git_status float"),
            { silent = true, desc = "Neotree git status float" },
        },
        {
            "D",
            keymap.cmd("Neotree diagnostics float"),
            { silent = true, desc = "Neotree diagnostics float" },
        },
        {
            "r",
            keymap.cmd("Ranger"),
            { silent = true, desc = "Ranger" },
        },
        {
            "v",
            keymap.cmd("Vifm"),
            { silent = true, desc = "Vifm" },
        },
        {
            "O",
            keymap.cmd("Oil"),
            { silent = true, desc = "Oil" },
        },
        {
            "f",
            keymap.cmd("LvimFileManager"),
            { silent = true, desc = "LVIM file manager" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
