local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local comment_annotation_hint = [[
                COMMENT, ANNOTATION, FOLD

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Comment toggle line         _L_ │ _b_       Comment toggle block

Neogen file                 _F_ │ _t_                Neogen type
Neogen class                _c_ │ _f_            Neogen function

Manual                      _m_ │ _I_                     Indent
Expr                        _e_ │ _d_                       Diff
Marker                      _r_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

M.comment_annotation_hint = Hydra({
    name = "COMMENT and ANNOTATION",
    hint = comment_annotation_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";a",
    heads = {
        {
            "L",
            "<Plug>(comment_toggle_linewise_current)",
            { nowait = true, silent = true, desc = "Comment toggle line" },
        },
        {
            "b",
            "<Plug>(comment_toggle_blockwise)",
            { nowait = true, silent = true, desc = "Comment toggle block" },
        },
        {
            "F",
            keymap.cmd("NeogenFile"),
            { nowait = true, silent = true, desc = "Neogen file" },
        },
        {
            "t",
            keymap.cmd("NeogenType"),
            { nowait = true, silent = true, desc = "Neogen type" },
        },
        {
            "c",
            keymap.cmd("NeogenClass"),
            { nowait = true, silent = true, desc = "Neogen class" },
        },
        {
            "f",
            keymap.cmd("NeogenFunction"),
            { nowait = true, silent = true, desc = "Neogen function" },
        },
        {
            "m",
            keymap.cmd("set foldmethod=manual"),
            { nowait = true, silent = true, desc = "Manual" },
        },
        {
            "I",
            keymap.cmd("set foldmethod=indent"),
            { nowait = true, silent = true, desc = "Indent" },
        },
        {
            "e",
            keymap.cmd("set foldmethod=expr"),
            { nowait = true, silent = true, desc = "Expr" },
        },
        {
            "d",
            keymap.cmd("set foldmethod=diff"),
            { nowait = true, silent = true, desc = "Diff" },
        },
        {
            "r",
            keymap.cmd("set foldmethod=marker"),
            { nowait = true, silent = true, desc = "Marker" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})

return M
