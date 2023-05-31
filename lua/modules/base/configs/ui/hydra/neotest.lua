local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local neotest_hint = [[
                           NEOTEST

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Run                         _r_ │ _c_                Run current
Run with dap                _d_ │ _A_                     Attach
Output                      _O_ │ _S_                    Summary
Stop                        _s_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]

Hydra({
    name = "NEOTEST",
    hint = neotest_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";'",
    heads = {
        {
            "r",
            keymap.cmd("NeotestRun"),
            { nowait = true, silent = true, desc = "Run" },
        },
        {
            "c",
            keymap.cmd("NeotestRunCurrent"),
            { nowait = true, silent = true, desc = "Run current" },
        },
        {
            "d",
            keymap.cmd("NeotestRunDap"),
            { nowait = true, silent = true, desc = "Run with dap" },
        },
        {
            "A",
            keymap.cmd("NeotestAttach"),
            { nowait = true, silent = true, desc = "Attach" },
        },
        {
            "O",
            keymap.cmd("NeotestOutput"),
            { nowait = true, silent = true, desc = "Output" },
        },
        {
            "S",
            keymap.cmd("NeotestSummary"),
            { nowait = true, silent = true, desc = "Summary" },
        },
        {
            "s",
            keymap.cmd("NeotestStop"),
            { nowait = true, silent = true, desc = "Stop" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
