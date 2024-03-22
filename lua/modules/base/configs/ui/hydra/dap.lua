local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local dap_hint = [[
                                           DAP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Breakpoint toggle                     _<A-1>_ │ _<A-2>_                              Continue
Step into                             _<A-3>_ │ _<A-4>_                             Step over
Step out                              _<A-5>_ │ _<A-6>_                                    Up
Down                                  _<A-7>_ │ _<A-8>_                                 Close
Restart                               _<A-9>_ │ _<A-0>_                           Toggle repl

Run to cursor                   _<C-c><C-c>c_ │ _<C-c><C-c>p_                           Pause
Disconnect                      _<C-c><C-c>x_ │ _<C-c><C-c>g_                     Get session
UI close                        _<C-c><C-c>q_ │ _<C-c><C-c>f_                Dap local config
Lua dap launch                   _<C-c><C-l>_ │ _<C-c><C-c>X_               Breakpoints clear

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.dap = Hydra({
    name = "DAP",
    hint = dap_hint,
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
    body = ";d",
    heads = {
        {
            "<A-1>",
            keymap.cmd("DapToggleBreakpoint"),
            { nowait = true, silent = true, desc = "Breakpoint toggle" },
        },
        {
            "<A-2>",
            keymap.cmd("DapContinue"),
            { nowait = true, silent = true, desc = "Continue" },
        },
        {
            "<A-3>",
            keymap.cmd("DapStepInto"),
            { nowait = true, silent = true, desc = "Step into" },
        },
        {
            "<A-4>",
            keymap.cmd("DapStepOver"),
            { nowait = true, silent = true, desc = "Step over" },
        },
        {
            "<A-5>",
            keymap.cmd("DapStepOut"),
            { nowait = true, silent = true, desc = "Step out" },
        },
        {
            "<A-6>",
            keymap.cmd("DapUp"),
            { nowait = true, silent = true, desc = "Up" },
        },
        {
            "<A-7>",
            keymap.cmd("DapDown"),
            { nowait = true, silent = true, desc = "Down" },
        },
        {
            "<A-8>",
            function()
                keymap.cmd("DapClose")
                keymap.cmd("DapDisconnect")
                keymap.cmd("DapUIClose")
            end,
            { nowait = true, silent = true, desc = "Close" },
        },
        {
            "<A-9>",
            keymap.cmd("DapRestart"),
            { nowait = true, silent = true, desc = "Restart" },
        },
        {
            "<A-0>",
            keymap.cmd("DapToggleRepl"),
            { nowait = true, silent = true, desc = "Toggle repl" },
        },

        {
            "<C-c><C-c>c",
            keymap.cmd("DapRunToCursor"),
            { nowait = true, silent = true, desc = "Run to cursor" },
        },
        {
            "<C-c><C-c>p",
            keymap.cmd("DapPause"),
            { nowait = true, silent = true, desc = "Pause" },
        },
        {
            "<C-c><C-c>x",
            keymap.cmd("DapDisconnect"),
            { nowait = true, silent = true, desc = "Disconnect" },
        },
        {
            "<C-c><C-c>g",
            keymap.cmd("DapGetSession"),
            { nowait = true, silent = true, desc = "Get session" },
        },
        {
            "<C-c><C-c>q",
            keymap.cmd("DapUIClose"),
            { nowait = true, silent = true, desc = "UI close" },
        },
        {
            "<C-c><C-c>f",
            keymap.cmd("DAPLocal"),
            { nowait = true, silent = true, desc = "Dap local config" },
        },
        {
            "<C-c><C-l>",
            keymap.cmd("LuaDapLaunch"),
            { nowait = true, silent = true, desc = "Lua dap launch" },
        },
        {
            "<C-c><C-c>X",
            keymap.cmd("DapClearBreakpoints"),
            { nowait = true, silent = true, desc = "Breakpoints clear" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
