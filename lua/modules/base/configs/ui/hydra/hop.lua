local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local hop_hint = [[
                             HOP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Hop word                    _w_ │ _a_               Hop anywhere
Hop char 1                  _c_ │ _C_                 Hop char 2
Hop line                    _n_ │ _s_             Hop line start

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

M.hop = Hydra({
    name = "HOP",
    hint = hop_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";h",
    heads = {
        {
            "w",
            keymap.cmd("HopWord"),
            { nowait = true, silent = true, desc = "Hop word" },
        },
        {
            "a",
            keymap.cmd("HopAnywhere"),
            { nowait = true, silent = true, desc = "Hop anywhere" },
        },
        {
            "c",
            keymap.cmd("HopChar1"),
            { nowait = true, silent = true, desc = "Hop char 1" },
        },
        {
            "C",
            keymap.cmd("HopChar2"),
            { nowait = true, silent = true, desc = "Hop char 2" },
        },
        {
            "n",
            keymap.cmd("HopLine"),
            { nowait = true, silent = true, desc = "Hop line" },
        },
        {
            "s",
            keymap.cmd("HopLineStart"),
            { nowait = true, silent = true, desc = "Hop line start" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})

return M
