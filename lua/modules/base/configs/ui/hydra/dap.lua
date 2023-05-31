local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local dap_hint = [[
                             DAP

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Breakpoint toggle           _b_ │ _q_          Breakpoints clear
Run to cursor               _C_ │ _c_                   Continue
Step over                   _O_ │ _u_                         Up
Step into                   _I_ │ _d_                       Down
Step out                    _t_ │ _p_                      Pause
Close                       _x_ │ _X_                 Disconnect
Restart                     _R_ │ _r_                Toggle repl
Get session                 _g_ │ _s_                   UI close
Lua dap launch              _U_ │ _L_           Dap local config

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
    name = "DAP",
    hint = dap_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";p",
    heads = {
        {
            "b",
            keymap.cmd("DapToggleBreakpoint"),
            { silent = true, desc = "Breakpoint toggle" },
        },
        {
            "q",
            keymap.cmd("DapClearBreakpoints"),
            { silent = true, desc = "Breakpoints clear" },
        },
        {
            "C",
            keymap.cmd("DapRunToCursor"),
            { silent = true, desc = "Run to cursor" },
        },
        {
            "c",
            keymap.cmd("DapContinue"),
            { silent = true, desc = "Continue" },
        },
        {
            "O",
            keymap.cmd("DapStepOver"),
            { silent = true, desc = "Step over" },
        },
        {
            "I",
            keymap.cmd("DapStepInto"),
            { silent = true, desc = "Step into" },
        },
        {
            "t",
            keymap.cmd("DapStepOut"),
            { silent = true, desc = "Step out" },
        },
        {
            "u",
            keymap.cmd("DapUp"),
            { silent = true, desc = "Up" },
        },
        {
            "d",
            keymap.cmd("DapDown"),
            { silent = true, desc = "Down" },
        },
        {
            "p",
            keymap.cmd("DapPause"),
            { silent = true, desc = "Pause" },
        },
        {
            "x",
            keymap.cmd("DapClose"),
            { silent = true, desc = "Close" },
        },
        {
            "X",
            keymap.cmd("DapDisconnect"),
            { silent = true, desc = "Disconnect" },
        },
        {
            "R",
            keymap.cmd("DapRestart"),
            { silent = true, desc = "Restart" },
        },
        {
            "r",
            keymap.cmd("DapToggleRepl"),
            { silent = true, desc = "Toggle repl" },
        },
        {
            "g",
            keymap.cmd("DapGetSession"),
            { silent = true, desc = "Get session" },
        },
        {
            "s",
            keymap.cmd("DapUIClose"),
            { silent = true, desc = "UI close" },
        },
        {
            "U",
            keymap.cmd("LuaDapLaunch"),
            { silent = true, desc = "Lua dap launch" },
        },
        {
            "L",
            keymap.cmd("DAPLocal"),
            { silent = true, desc = "Dap local config" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
