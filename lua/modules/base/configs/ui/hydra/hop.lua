local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local hop_hint = [[
                             HOP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Hop word                    _h_ │ _a_               Hop anywhere
Hop char 1                  _c_ │ _C_                 Hop char 2
Hop line                    _l_ │ _s_             Hop line start

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
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
    body = "<leader>h",
    heads = {
        {
            "h",
            keymap.cmd("HopWord"),
            { silent = true, desc = "Hop word" },
        },
        {
            "a",
            keymap.cmd("HopAnywhere"),
            { silent = true, desc = "Hop anywhere" },
        },
        {
            "c",
            keymap.cmd("HopChar1"),
            { silent = true, desc = "Hop char 1" },
        },
        {
            "C",
            keymap.cmd("HopChar2"),
            { silent = true, desc = "Hop char 2" },
        },
        {
            "l",
            keymap.cmd("HopLine"),
            { silent = true, desc = "Hop line" },
        },
        {
            "s",
            keymap.cmd("HopLineStart"),
            { silent = true, desc = "Hop line start" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
