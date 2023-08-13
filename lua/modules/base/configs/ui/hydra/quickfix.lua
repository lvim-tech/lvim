local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local quickfix_hint = "                                        QUICKFIX\n\n"
quickfix_hint = quickfix_hint
    .. "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\n"
quickfix_hint = quickfix_hint
    .. "Prev                                     _][_ │ _]]_                                     Next\n"
quickfix_hint = quickfix_hint
    .. "Open                                     _]o_ │ _]q_                              Menu delete\n"
quickfix_hint = quickfix_hint
    .. "Menu choice                              _]c_ │ _]d_                              Menu delete\n"
quickfix_hint = quickfix_hint
    .. "Load                                     _]l_ │ _]s_                                     Save\n\n"
quickfix_hint = quickfix_hint
    .. "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\n"
quickfix_hint = quickfix_hint .. "                                       exit │ _<C-q>_"

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
            "][",
            keymap.cmd("LvimListQuickFixPrev"),
            { nowait = true, silent = true, desc = "Prev" },
        },
        {
            "]]",
            keymap.cmd("LvimListQuickFixNext"),
            { nowait = true, silent = true, desc = "Next" },
        },
        {
            "]o",
            keymap.cmd("copen"),
            { nowait = true, silent = true, desc = "Open" },
        },
        {
            "]q",
            keymap.cmd("cclose"),
            { nowait = true, silent = true, desc = "Close" },
        },
        {
            "]c",
            keymap.cmd("LvimListQuickFixMenuChoice"),
            { nowait = true, silent = true, desc = "Menu choice" },
        },
        {
            "]d",
            keymap.cmd("LvimListQuickFixMenuDelete"),
            { nowait = true, silent = true, desc = "Menu delete" },
        },
        {
            "]l",
            keymap.cmd("LvimListQuickFixMenuLoad"),
            { nowait = true, silent = true, desc = "Load" },
        },
        {
            "]s",
            keymap.cmd("LvimListQuickFixMenuSave"),
            { nowait = true, silent = true, desc = "Save" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
