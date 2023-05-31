local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local location_hint = [[
                          LOCATION

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Prev                        _p_ │ _n_                       Next
Choice                      _c_ │ _d_                     Delete
Load                        _L_ │ _s_                       Save

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
    name = "LOCATION",
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
    body = ";o",
    heads = {
        {
            "p",
            keymap.cmd("LvimListLocPrev"),
            { silent = true, desc = "Prev" },
        },
        {
            "n",
            keymap.cmd("LvimListLocNext"),
            { silent = true, desc = "Next" },
        },
        {
            "c",
            keymap.cmd("LvimListQuicLocChoice"),
            { silent = true, desc = "Choice" },
        },
        {
            "d",
            keymap.cmd("LvimListQuicLocDelete"),
            { silent = true, desc = "Delete" },
        },
        {
            "L",
            keymap.cmd("LvimListLocLoad"),
            { silent = true, desc = "Load" },
        },
        {
            "s",
            keymap.cmd("LvimListLocSave"),
            { silent = true, desc = "Save" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
