local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local quickfix_hint = [[
                          QUICKFIX

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Prev                        _p_ │ _n_                       Next
Choice                      _c_ │ _d_                     Delete
Load                        _l_ │ _s_                       Save

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
    name = "QUICKFIX",
    hint = quickfix_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = "<leader>q",
    heads = {
        {
            "p",
            keymap.cmd("LvimListQuickFixPrev"),
            { silent = true, desc = "Prev" },
        },
        {
            "n",
            keymap.cmd("LvimListQuickFixNext"),
            { silent = true, desc = "Next" },
        },
        {
            "c",
            keymap.cmd("LvimListQuickFixMenuChoice"),
            { silent = true, desc = "Choice" },
        },
        {
            "d",
            keymap.cmd("LvimListQuickFixMenuDelete"),
            { silent = true, desc = "Delete" },
        },
        {
            "l",
            keymap.cmd("LvimListQuickFixLoad"),
            { silent = true, desc = "Load" },
        },
        {
            "s",
            keymap.cmd("LvimListQuickFixSave"),
            { silent = true, desc = "Save" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
