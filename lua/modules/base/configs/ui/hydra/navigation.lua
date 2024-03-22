local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local navigation_hint = [[
                                       NAVIGATION

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Save                                 _<C-c>s_ │ _<C-c>a_                             Save all

Tab next                             _<C-c>n_ │ _<C-c>p_                             Tab prev

Close current window                 _<C-c>x_ │ _<C-c>o_                  Close other windows
Window zoom toggle                   _<C-c>z_ │ _<C-c>=_                      Window resize =
Vertical resize -2                        _H_ │ _L_                        Vertical resize +2
Resize -2                                 _J_ │ _K_                                 Resize +2
Window move                          _<C-c>w_ │

Move to window left                   _<C-h>_ │ _<C-l>_                  Move to window right
Move to window down                   _<C-j>_ │ _<C-k>_                     Move to window up

Create empty buffer                  _<C-c>N_ │ _<C-c>d_                       Bdelete buffer
Bnext buffer                          _<C-n>_ │ _<C-p>_                          Bprev buffer

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.navigation = Hydra({
    name = "NAVIGATION",
    hint = navigation_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            float_opts = {
                border = "single",
            },
        },
    },
    mode = { "n", "x", "v" },
    body = ";n",
    heads = {
        {
            "<C-c>s",
            keymap.cmd("w"),
            { nowait = true, silent = true, desc = "Save" },
        },
        {
            "<C-c>a",
            keymap.cmd("wa"),
            { nowait = true, silent = true, desc = "Save all" },
        },
        {
            "<C-c>n",
            keymap.cmd("tabn"),
            { nowait = true, silent = true, desc = "Tab next" },
        },
        {
            "<C-c>p",
            keymap.cmd("tabp"),
            { nowait = true, silent = true, desc = "Tab prev" },
        },
        {
            "<C-c>x",
            "<C-w>c",
            { nowait = true, silent = true, desc = "Close current window" },
        },
        {
            "<C-c>o",
            "<C-w>o",
            { nowait = true, silent = true, desc = "Close other windows" },
        },
        {
            "<C-c>z",
            keymap.cmd("NeoZoom"),
            { nowait = true, silent = true, desc = "Window zoom toggle" },
        },
        {
            "<C-c>=",
            keymap.cmd("wincmd="),
            { nowait = true, silent = true, desc = "Window resize =" },
        },
        {
            "L",
            keymap.cmd("vertical resize +2"),
            { nowait = true, silent = true, desc = "Window resize width +" },
        },
        {
            "H",
            keymap.cmd("vertical resize -2"),
            { nowait = true, silent = true, desc = "Window resize width -" },
        },
        {
            "K",
            keymap.cmd("resize +2"),
            { nowait = true, silent = true, desc = "Window resize height +" },
        },
        {
            "J",
            keymap.cmd("resize -2"),
            { nowait = true, silent = true, desc = "Window resize height -" },
        },
        {
            "<C-c>w",
            function()
                keymap.cmd("Neotree close")
                keymap.cmd("WinShift")
            end,
            { nowait = true, silent = true, desc = "Window move" },
        },
        {
            "<C-h>",
            "<C-w>h",
            { nowait = true, silent = true, desc = "Move to window left" },
        },
        {
            "<C-l>",
            "<C-w>l",
            { nowait = true, silent = true, desc = "Move to window right" },
        },
        {
            "<C-j>",
            "<C-w>j",
            { nowait = true, silent = true, desc = "Move to window down" },
        },
        {
            "<C-k>",
            "<C-w>k",
            { nowait = true, silent = true, desc = "Move to window up" },
        },
        {
            "<C-c>N",
            keymap.cmd("enew"),
            { nowait = true, silent = true, desc = "Create empty buffer" },
        },
        {
            "<C-c>d",
            keymap.cmd("bdelete"),
            { nowait = true, silent = true, desc = "Bdelete buffer" },
        },
        {
            "<C-n>",
            keymap.cmd("BufSurfForward"),
            { nowait = true, silent = true, desc = "Bnext buffer" },
        },
        {
            "<C-p>",
            keymap.cmd("BufSurfBack"),
            { nowait = true, silent = true, desc = "Bprev buffer" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
