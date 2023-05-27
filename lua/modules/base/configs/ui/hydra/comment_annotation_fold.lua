local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local comment_annotation_hint = [[
                COMMENT, ANNOTATION, FOLD

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Comment toggle line         _L_ │ _b_       Comment toggle block

Neogen file                 _F_ │ _t_                Neogen type
Neogen class                _c_ │ _f_            Neogen function

Manual                      _m_ │ _i_                     Indent
Expr                        _e_ │ _d_                       Diff
Marker                      _r_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
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
    body = "<leader>c",
    heads = {
        {
            "l",
            "<Plug>(comment_toggle_linewise_current)",
            { silent = true, desc = "Comment toggle line" },
        },
        {
            "b",
            "<Plug>(comment_toggle_blockwise)",
            { silent = true, desc = "Comment toggle block" },
        },
        {
            "F",
            keymap.cmd("NeogenFile"),
            { silent = true, desc = "Neogen file" },
        },
        {
            "t",
            keymap.cmd("NeogenType"),
            { silent = true, desc = "Neogen type" },
        },
        {
            "c",
            keymap.cmd("NeogenClass"),
            { silent = true, desc = "Neogen class" },
        },
        {
            "f",
            keymap.cmd("NeogenFunction"),
            { silent = true, desc = "Neogen function" },
        },
        {
            "m",
            keymap.cmd("set foldmethod=manual"),
            { silent = true, desc = "Manual" },
        },
        {
            "i",
            keymap.cmd("set foldmethod=indent"),
            { silent = true, desc = "Indent" },
        },
        {
            "e",
            keymap.cmd("set foldmethod=expr"),
            { silent = true, desc = "Expr" },
        },
        {
            "d",
            keymap.cmd("set foldmethod=diff"),
            { silent = true, desc = "Diff" },
        },
        {
            "r",
            keymap.cmd("set foldmethod=marker"),
            { silent = true, desc = "Marker" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
