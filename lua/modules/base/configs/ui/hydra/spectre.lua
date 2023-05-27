local Hydra = require("hydra")
local keymap = require("hydra.keymap-util")

local spectre_hint = [[
                           SPECTRE

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
Open                        _o_ │ _h_                Show option
Toggle line                 _t_ │ _r_        Run current replace
Select entry             _<CR>_ │ _R_                Run replace
Send to quickfix            _q_ │ _u_         Toggle live update
Replace command             _m_ │ _v_                Change view
Toggle ignore case          _I_ │ _l_         Resume last search
Toggle hidden               _H_ │

▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
                         exit _<Esc>_
]]
Hydra({
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
    body = "<leader>r",
    heads = {
        {
            "o",
            keymap.cmd("Spectre"),
            { silent = true, desc = "Open" },
        },
        {
            "t",
            keymap.cmd("SpectreToggleLine"),
            { silent = true, desc = "Toggle line" },
        },
        {
            "<CR>",
            keymap.cmd("SpectreSelectEntry"),
            { silent = true, desc = "Select entry" },
        },
        {
            "q",
            keymap.cmd("SpectreSendToQF"),
            { silent = true, desc = "Send to quickfix" },
        },
        {
            "m",
            keymap.cmd("SpectreReplaceCommand"),
            { silent = true, desc = "Replace command" },
        },
        {
            "r",
            keymap.cmd("SpectreRunCurrentReplace"),
            { silent = true, desc = "Run current replace" },
        },
        {
            "R",
            keymap.cmd("SpectreRunReplace"),
            { silent = true, desc = "Run replace" },
        },
        {
            "I",
            keymap.cmd("SpectreIgnoreCase"),
            { silent = true, desc = "Toggle ignore case" },
        },
        {
            "H",
            keymap.cmd("SpectreHidden"),
            { silent = true, desc = "Toggle hidden" },
        },
        {
            "u",
            keymap.cmd("SpectreToggleLiveUpdate"),
            { silent = true, desc = "Toggle live update" },
        },
        {
            "v",
            keymap.cmd("SpectreChangeView"),
            { silent = true, desc = "Change view" },
        },
        {
            "l",
            keymap.cmd("SpectreResumeLastSearch"),
            { silent = true, desc = "Resume last search" },
        },
        {
            "h",
            keymap.cmd("SpectreShowOptions"),
            { silent = true, desc = "Show option" },
        },
        { "<Esc>", nil, { exit = true, desc = false } },
    },
})
