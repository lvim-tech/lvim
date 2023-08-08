local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local M = {}

local spectre_hint = [[
                           SPECTRE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Open                        _O_ │ _P_                Show option
Toggle line                 _g_ │ _r_        Run current replace
Select entry             _<CR>_ │ _R_                Run replace
Send to quickfix            _q_ │ _u_         Toggle live update
Replace command             _m_ │ _v_                Change view
Toggle ignore case          _I_ │ _L_         Resume last search
Toggle hidden               _H_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<C-q>_
]]

M.replace = Hydra({
    name = "SPECTRE",
    hint = spectre_hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-left",
            border = "single",
        },
    },
    mode = { "n", "x", "v" },
    body = ";r",
    heads = {
        {
            "O",
            keymap.cmd("Spectre"),
            { nowait = true, silent = true, desc = "Open" },
        },
        {
            "g",
            keymap.cmd("SpectreToggleLine"),
            { nowait = true, silent = true, desc = "Toggle line" },
        },
        {
            "<CR>",
            keymap.cmd("SpectreSelectEntry"),
            { nowait = true, silent = true, desc = "Select entry" },
        },
        {
            "q",
            keymap.cmd("SpectreSendToQF"),
            { nowait = true, silent = true, desc = "Send to quickfix" },
        },
        {
            "m",
            keymap.cmd("SpectreReplaceCommand"),
            { nowait = true, silent = true, desc = "Replace command" },
        },
        {
            "r",
            keymap.cmd("SpectreRunCurrentReplace"),
            { nowait = true, silent = true, desc = "Run current replace" },
        },
        {
            "R",
            keymap.cmd("SpectreRunReplace"),
            { nowait = true, silent = true, desc = "Run replace" },
        },
        {
            "I",
            keymap.cmd("SpectreIgnoreCase"),
            { nowait = true, silent = true, desc = "Toggle ignore case" },
        },
        {
            "H",
            keymap.cmd("SpectreHidden"),
            { nowait = true, silent = true, desc = "Toggle hidden" },
        },
        {
            "u",
            keymap.cmd("SpectreToggleLiveUpdate"),
            { nowait = true, silent = true, desc = "Toggle live update" },
        },
        {
            "v",
            keymap.cmd("SpectreChangeView"),
            { nowait = true, silent = true, desc = "Change view" },
        },
        {
            "L",
            keymap.cmd("SpectreResumeLastSearch"),
            { nowait = true, silent = true, desc = "Resume last search" },
        },
        {
            "P",
            keymap.cmd("SpectreShowOptions"),
            { nowait = true, silent = true, desc = "Show option" },
        },
        { "<C-q>", nil, { exit = true, desc = false } },
    },
})

return M
