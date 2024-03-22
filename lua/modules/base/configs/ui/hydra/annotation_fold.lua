local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local annotation_hint = [[
                                   ANNOTATION, FOLD

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Neogen file                     _<C-c><C-c>f_ │ _<C-c><C-c>t_                     Neogen type
Neogen class                    _<C-c><C-c>c_ │ _<C-c><C-c>u_                 Neogen function

Manual                          _<C-c><C-c>m_ │ _<C-c><C-c>n_                          Indent
Expr                            _<C-c><C-c>e_ │ _<C-c><C-c>i_                            Diff
Marker                          _<C-c><C-c>r_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.annotation = Hydra({
    name = "COMMENT, ANNOTATION, FOLD",
    hint = annotation_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    mode = { "n", "x", "v" },
    body = ";c",
    heads = {
        {
            "<C-c><C-c>f",
            keymap.cmd("NeogenFile"),
            { nowait = true, silent = true, desc = "Neogen file" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("NeogenType"),
            { nowait = true, silent = true, desc = "Neogen type" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("NeogenClass"),
            { nowait = true, silent = true, desc = "Neogen class" },
        },
        {
            "<C-c><C-c>u",
            keymap.cmd("NeogenFunction"),
            { nowait = true, silent = true, desc = "Neogen function" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("set foldmethod=manual"),
            { nowait = true, silent = true, desc = "Manual" },
        },
        {
            "<C-c><C-c>n",
            keymap.cmd("set foldmethod=indent"),
            { nowait = true, silent = true, desc = "Indent" },
        },
        {
            "<C-c><C-c>e",
            keymap.cmd("set foldmethod=expr"),
            { nowait = true, silent = true, desc = "Expr" },
        },
        {
            "<C-c><C-c>i",
            keymap.cmd("set foldmethod=diff"),
            { nowait = true, silent = true, desc = "Diff" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("set foldmethod=marker"),
            { nowait = true, silent = true, desc = "Marker" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
