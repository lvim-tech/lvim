local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local comment_annotation_hint = [[
                COMMENT, ANNOTATION, FOLD

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Comment toggle line N       _L_ │ _B_     Comment toggle block N
Comment toggle line V      _vl_ │ _vb_    Comment toggle block V

Neogen file                 _F_ │ _t_                Neogen type
Neogen class                _c_ │ _f_            Neogen function

Manual                      _m_ │ _I_                     Indent
Expr                        _e_ │ _d_                       Diff
Marker                      _r_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<C-q>_
]]

M.comment_annotation_hint = Hydra({
    name = "COMMENT, ANNOTATION, FOLD",
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
    body = ";c",
    heads = {
        {
            "L",
            "<Plug>(comment_toggle_linewise_current)",
            { nowait = true, silent = true, desc = "Comment toggle line N" },
        },
        {
            "B",
            "<Plug>(comment_toggle_blockwise_current)",
            { nowait = true, silent = true, desc = "Comment toggle block N" },
        },
        {
            "vl",
            "<Plug>(comment_toggle_linewise_visual)",
            { nowait = true, silent = true, desc = "Comment toggle line V " },
        },
        {
            "vb",
            "<Plug>(comment_toggle_blockwise_visual)",
            { nowait = true, silent = true, desc = "Comment toggle block V" },
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
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
