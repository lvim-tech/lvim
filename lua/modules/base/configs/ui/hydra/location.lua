local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local location_hint = "                                        LOCATION\n\n"
location_hint = location_hint
    .. "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\n"
location_hint = location_hint
    .. "Prev                                     _[[_ │ _[]_                                     Next\n"
location_hint = location_hint
    .. "Open                                     _[o_ │ _[q_                              Menu delete\n"
location_hint = location_hint
    .. "Menu choice                              _[c_ │ _[d_                              Menu delete\n"
location_hint = location_hint
    .. "Load                                     _[l_ │ _[s_                                     Save\n\n"
location_hint = location_hint
    .. "▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔\n"
location_hint = location_hint .. "                                       exit │ _<C-q>_"

M.location = Hydra({
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
            "[[",
            keymap.cmd("LvimListLocPrev"),
            { nowait = true, silent = true, desc = "Prev" },
        },
        {
            "[]",
            keymap.cmd("LvimListLocNext"),
            { nowait = true, silent = true, desc = "Next" },
        },
        {
            "[o",
            keymap.cmd("lopen"),
            { nowait = true, silent = true, desc = "Open" },
        },
        {
            "[q",
            keymap.cmd("lclose"),
            { nowait = true, silent = true, desc = "Close" },
        },
        {
            "[c",
            keymap.cmd("LvimListLocMenuChoice"),
            { nowait = true, silent = true, desc = "Menu choice" },
        },
        {
            "[d",
            keymap.cmd("LvimListLocMenuDelete"),
            { nowait = true, silent = true, desc = "Menu delete" },
        },
        {
            "[l",
            keymap.cmd("LvimListLocMenuLoad"),
            { nowait = true, silent = true, desc = "Load" },
        },
        {
            "[s",
            keymap.cmd("LvimListLocMenuSave"),
            { nowait = true, silent = true, desc = "Save" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
