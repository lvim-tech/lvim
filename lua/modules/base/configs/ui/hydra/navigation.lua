local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local navigation_hint = [[
                         NAVIGATION

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Save                        _s_ │ _S_                   Save all

Tab next                _<C-n>_ │ _<C-p>_               Tab prev

Close current window        _x_ │ _O_        Close other windows
Window zoom toggle          _r_ │ _=_            Window resize =
Window resize width +   _<A-l>_ │ _<A-h>_  Window resize width -
Window resize height +  _<A-j>_ │ _<A-k>_ Window resize height -
Window move             _<A-m>_ │

Move to window left         _H_ │ _L_       Move to window right
Move to window down         _J_ │ _K_          Move to window up

Create empty buffer         _e_ │ _d_             Bdelete buffer
Bnext buffer                _n_ │ _p_               Bprev buffer

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

Hydra({
    name = "NAVIGATION",
    hint = navigation_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";n",
    heads = {
        {
            "s",
            keymap.cmd("w"),
            { nowait = true, silent = true, desc = "Save" },
        },
        {
            "S",
            keymap.cmd("wa"),
            { nowait = true, silent = true, desc = "Save all" },
        },
        {
            "<C-n>",
            keymap.cmd("tabn"),
            { nowait = true, silent = true, desc = "Tab next" },
        },
        {
            "<C-p>",
            keymap.cmd("tabp"),
            { nowait = true, silent = true, desc = "Tab prev" },
        },
        {
            "x",
            "<C-w>c",
            { nowait = true, silent = true, desc = "Close current window" },
        },
        {
            "O",
            "<C-w>o",
            { nowait = true, silent = true, desc = "Close other windows" },
        },
        {
            "r",
            keymap.cmd("NeoZoom"),
            { nowait = true, silent = true, desc = "Window zoom toggle" },
        },
        {
            "=",
            keymap.cmd("wincmd="),
            { nowait = true, silent = true, desc = "Window resize =" },
        },
        {
            "<A-l>",
            keymap.cmd("vertical resize +2"),
            { nowait = true, silent = true, desc = "Window resize width +" },
        },
        {
            "<A-h>",
            keymap.cmd("vertical resize -2"),
            { nowait = true, silent = true, desc = "Window resize width -" },
        },
        {
            "<A-j>",
            keymap.cmd("resize +2"),
            { nowait = true, silent = true, desc = "Window resize height +" },
        },
        {
            "<A-k>",
            keymap.cmd("resize -2"),
            { nowait = true, silent = true, desc = "Window resize height -" },
        },
        {
            "<A-m>",
            keymap.cmd("WinShift"),
            { nowait = true, silent = true, desc = "Window move" },
        },
        {
            "H",
            "<C-w>h",
            { nowait = true, silent = true, desc = "Move to window left" },
        },
        {
            "L",
            "<C-w>l",
            { nowait = true, silent = true, desc = "Move to window right" },
        },
        {
            "J",
            "<C-w>j",
            { nowait = true, silent = true, desc = "Move to window down" },
        },
        {
            "K",
            "<C-w>k",
            { nowait = true, silent = true, desc = "Move to window up" },
        },
        {
            "e",
            keymap.cmd("enew"),
            { nowait = true, silent = true, desc = "Create empty buffer" },
        },
        {
            "d",
            keymap.cmd("bdelete"),
            { nowait = true, silent = true, desc = "Bdelete buffer" },
        },
        {
            "n",
            keymap.cmd("BufSurfForward"),
            { nowait = true, silent = true, desc = "Bnext buffer" },
        },
        {
            "p",
            keymap.cmd("BufSurfBack"),
            { nowait = true, silent = true, desc = "Bprev buffer" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
