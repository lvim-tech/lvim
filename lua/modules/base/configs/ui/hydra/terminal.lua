local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local terminal_hint = [[
                                        TERMINAL

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Terminal horizontal 1                     _1_ │ _2_                     Terminal horizontal 2
Terminal horizontal 3                     _3_ │ _4_                     Terminal horizontal 4

Terminal vertical 1                       _5_ │ _6_                       Terminal vertical 2
Terminal vertical 3                       _7_ │ _8_                       Terminal vertical 4

Terminal float                            _9_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.terminal = Hydra({
    name = "TERMINAL",
    hint = terminal_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "top-center",
            float_opts = {
                border = "single",
            },
        },
    },
    mode = { "n", "x", "v" },
    body = ";m",
    heads = {
        {
            "1",
            keymap.cmd("TerminalHorizontal1"),
            { nowait = true, silent = true, desc = "Terminal horizontal 1" },
        },
        {
            "2",
            keymap.cmd("TerminalHorizontal2"),
            { nowait = true, silent = true, desc = "Terminal horizontal 2" },
        },
        {
            "3",
            keymap.cmd("TerminalHorizontal3"),
            { nowait = true, silent = true, desc = "Terminal horizontal 3" },
        },
        {
            "4",
            keymap.cmd("TerminalHorizontal4"),
            { nowait = true, silent = true, desc = "Terminal horizontal 4" },
        },
        {
            "5",
            keymap.cmd("TerminalVertical1"),
            { nowait = true, silent = true, desc = "Terminal vertical 1" },
        },
        {
            "6",
            keymap.cmd("TerminalVertical2"),
            { nowait = true, silent = true, desc = "Terminal vertical 6" },
        },
        {
            "7",
            keymap.cmd("TerminalVertical3"),
            { nowait = true, silent = true, desc = "Terminal vertical 7" },
        },
        {
            "8",
            keymap.cmd("TerminalVertical4"),
            { nowait = true, silent = true, desc = "Terminal vertical 8" },
        },
        {
            "9",
            keymap.cmd("TerminalFloat"),
            { nowait = true, silent = true, desc = "Terminal float" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
