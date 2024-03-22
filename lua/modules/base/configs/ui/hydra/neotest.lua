local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local neotest_hint = [[
                                        NEOTEST

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Run                             _<C-c><C-c>r_ │ _<C-c><C-c>c_                     Run current
Run with dap                    _<C-c><C-c>d_ │ _<C-c><C-c>a_                          Attach
Output                          _<C-c><C-c>o_ │ _<C-c><C-c>m_                         Summary
Stop                            _<C-c><C-c>s_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                                       exit │ _<C-q>_
]]

M.neotest = Hydra({
    name = "NEOTEST",
    hint = neotest_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-center",
        },
    },
    mode = { "n", "x", "v" },
    body = ";'",
    heads = {
        {
            "<C-c><C-c>r",
            keymap.cmd("NeotestRun"),
            { nowait = true, silent = true, desc = "Run" },
        },
        {
            "<C-c><C-c>c",
            keymap.cmd("NeotestRunCurrent"),
            { nowait = true, silent = true, desc = "Run current" },
        },
        {
            "<C-c><C-c>d",
            keymap.cmd("NeotestRunDap"),
            { nowait = true, silent = true, desc = "Run with dap" },
        },
        {
            "<C-c><C-c>a",
            keymap.cmd("NeotestAttach"),
            { nowait = true, silent = true, desc = "Attach" },
        },
        {
            "<C-c><C-c>o",
            keymap.cmd("NeotestOutput"),
            { nowait = true, silent = true, desc = "Output" },
        },
        {
            "<C-c><C-c>m",
            keymap.cmd("NeotestSummary"),
            { nowait = true, silent = true, desc = "Summary" },
        },
        {
            "<C-c><C-c>s",
            keymap.cmd("NeotestStop"),
            { nowait = true, silent = true, desc = "Stop" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
