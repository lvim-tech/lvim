local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local flutter_hint = [[
                                        FLUTTER

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Run                             _<C-c><C-c>f_ │ _<C-c><C-c>r_                          Reload
Restart                         _<C-c><C-c>R_ │ _<C-c><C-c>q_                            Quit
Devices                         _<C-c><C-c>d_ │ _<C-c><C-c>m_                       Emulators
Outline                         _<C-c><C-c>o_ │ _<C-c><C-c>t_                       Dev tools
Dev tools activate              _<C-c><C-c>T_ │ _<C-c><C-c>l_                     LSP restart
Reanalyze                       _<C-c><C-c>a_ │ _<C-c><C-c>e_                          Rename
Super                           _<C-c><C-c>s_ │ _<C-c><C-c>D_                          Detach
Copy profiler url               _<C-c><C-c>u_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.flutter = Hydra({
    name = "FLUTTER",
    hint = flutter_hint,
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
    -- body = ";pf",
    heads = {
        {
            "<C-c><C-c>f",
            keymap.cmd("FlutterRun"),
            { nowait = true, silent = true, desc = "Flutter run" },
        },
        {
            "<C-c><C-c>r",
            keymap.cmd("FlutterReload"),
            { nowait = true, silent = true, desc = "Flutter reload" },
        },
        {
            "<C-c><C-c>R",
            keymap.cmd("FlutterRestart"),
            { nowait = true, silent = true, desc = "Flutter restart" },
        },
        {
            "<C-c><C-c>q",
            keymap.cmd("FlutterQuit"),
            { nowait = true, silent = true, desc = "Flutter quit" },
        },
        {
            "<C-c><C-c>d",
            keymap.cmd("FlutterDevices"),
            { nowait = true, silent = true, desc = "Flutter devices" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("FlutterEmulators"),
            { nowait = true, silent = true, desc = "Flutter emulators" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("FlutterOutlineToggle"),
            { nowait = true, silent = true, desc = "Flutter outline toggle" },
        },
        {
            "<C-c><C-c>t",
            keymap.cmd("FlutterDevTools"),
            { nowait = true, silent = true, desc = "Flutter dev tools" },
        },
        {
            "<C-c><C-c>T",
            keymap.cmd("FlutterDevToolsActivate"),
            { nowait = true, silent = true, desc = "Flutter dev tools activate" },
        },
        {
            "<C-c><C-c>l",
            keymap.cmd("FlutterLspRestart"),
            { nowait = true, silent = true, desc = "Flutter LSP restart" },
        },
        {
            "<C-c><C-c>a",
            keymap.cmd("FlutterReanalyze"),
            { nowait = true, silent = true, desc = "Flutter reanalyze" },
        },
        {
            "<C-c><C-c>e",
            keymap.cmd("FlutterRename"),
            { nowait = true, silent = true, desc = "Flutter rename" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("FlutterSuper"),
            { nowait = true, silent = true, desc = "Flutter super" },
        },
        {
            "<C-c><C-c>D",
            keymap.cmd("FlutterDetach"),
            { nowait = true, silent = true, desc = "Flutter detach" },
        },
        {
            "<C-c><C-c>u",
            keymap.cmd("FlutterCopyProfilerUrl"),
            { nowait = true, silent = true, desc = "Flutter copy profiler url" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
