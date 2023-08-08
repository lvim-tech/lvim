local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local quickfix_hint = [[
                          QUICKFIX

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Prev                        _p_ │ _n_                       Next
Choice                      _c_ │ _d_                     Delete
Load                        _L_ │ _s_                       Save

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<C-q>_
]]

M.quickfix = Hydra({
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
    body = ";q",
    heads = {
        {
            "p",
            keymap.cmd("LvimListQuickFixPrev"),
            { nowait = true, silent = true, desc = "Prev" },
        },
        {
            "n",
            keymap.cmd("LvimListQuickFixNext"),
            { nowait = true, silent = true, desc = "Next" },
        },
        {
            "c",
            keymap.cmd("LvimListQuickFixMenuChoice"),
            { nowait = true, silent = true, desc = "Choice" },
        },
        {
            "d",
            keymap.cmd("LvimListQuickFixMenuDelete"),
            { nowait = true, silent = true, desc = "Delete" },
        },
        {
            "L",
            keymap.cmd("LvimListQuickFixLoad"),
            { nowait = true, silent = true, desc = "Load" },
        },
        {
            "s",
            keymap.cmd("LvimListQuickFixSave"),
            { nowait = true, silent = true, desc = "Save" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
